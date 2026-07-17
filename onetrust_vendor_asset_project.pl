# SDE Project Log report from OneTrust for file to read

# module VendorLookup in same directory as script

#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use JSON qw(encode_json);
use lib '.';
use VendorLookup qw(read_vendor_file);


# usage:
#   perl script.pl input_file.txt

# output structure:
#
# %data = (
#     Vendor Name => {
#         Asset Name => [
#             {
#                 project => 'project_id_1'
#             },
#             {
#                 project => 'project_id_2'
#             }
#         ]
#     }
# );

my $file = shift @ARGV
    or die "Usage: $0 input.txt\n";

open my $fh, '<', $file
    or die "Cannot open $file: $!\n";

# read header row
my $header = <$fh>;
chomp $header;

# remove Windows carriage return if present
$header =~ s/\r$//;

# split header into columns
my @headers = split /\t/, $header, -1;

# remove unwanted whitespace
for (@headers) {
    s/^\s+|\s+$//g;
}

########################################################################
# map column names to positions - need this as no Text::CSV in GitBash #
########################################################################

my %col;

for my $i (0 .. $#headers) {
    $col{$headers[$i]} = $i;
}

# Check required columns exist - name in list is checked as a hash key
for my $required ('SDE Project ID', 'Name - Related (Vendors)', 'Name - Related (Assets)', 'SDE Project Status') {
    die "Missing column: $required\n"
        unless exists $col{$required};
}

# main output structure

my %data;
my %seen;

# read lines
while (<$fh>) {

    chomp;
    # remove carraige returns
    s/\r$//;

    # preserve empty trailing columns
    my @fields = split /\t/, $_, -1;

    # do not inlcude archived projects
    my $status = $fields[$col{'SDE Project Status'}];
    next if $status ne 'Active';

    # extract values
    my $project = $fields[$col{'SDE Project ID'}] // '';
    my $vendors = $fields[$col{'Name - Related (Vendors)'}] // '';
    my $assets = $fields[$col{'Name - Related (Assets)'}] // '';

    # remove surrounding quotes
    $vendors =~ s/^"(.*)"$/$1/;
    $assets  =~ s/^"(.*)"$/$1/;

    # if no project - create a no project value
    if (!$project) {
        $project = '[No Project ID]';
    }

    # split vendors
    my @vendor_list = split /\s*,\s*/, $vendors;

    # split assets
    my @asset_list = split /\s*,\s*/, $assets;

    # if no asset - create a no asset value
    if (!@asset_list || !$asset_list[0]) {
        @asset_list = ('[No Asset Listed]');
    }

    # data structure

    # vendor
    #    |
    #    +-- Asset
    #           |
    #           +-- { project => ID }

    for my $vendor (@vendor_list) {
        next unless $vendor;
        $vendor =~ s/^\s+|\s+$//g;

        for my $asset (@asset_list) {
            next unless $asset;
            $asset =~ s/^\s+|\s+$//g;

            # Prevent duplicate vendor/asset/project
            #
            my $unique_key = join('|', $vendor, $asset, $project);

            next if $seen{$unique_key};

            # store project as an array element
            # project - hash key, $project - hash value
            push @{ $data{$vendor}{$asset} },
                {
                    project => $project
                };

            # mark as seen
            $seen{$unique_key} = 1;
        }
    }
}
close $fh;

# check structure
# print Dumper(\%data);

# json file - do not use - contains archived vendors
open (my $dd,'>','OneTrust_vendor_asset_project_json_map.json');
my $json = JSON->new->pretty(1);
print $dd $json->encode(\%data);
close $dd;

# from the vendor status report on OneTrust - merge the vendor with the vendor from the project report, but filter on active vendors
# have vendor as hash key, and status as hash value

my $hash = read_vendor_file("vendor status.txt");

open (my $merge_out, '>', 'OneTrust_vendor_active_asset_project_map.txt');
print $merge_out "Vendor\tVendorStatus\tAsset\tProject\n";

for my $vendor (sort keys %{$hash}) {
    next if $vendor eq 'Jay Hughes' or $vendor eq 'Andrew Campbell' or $vendor eq 'Elizabeth Crellin' or $vendor eq 'Sophie Hodges';

    my $lookup_value = $hash->{$vendor};

    if (exists $data{$vendor}) {
        for my $asset (sort keys %{ $data{$vendor} }) {
            for my $project_record (@{ $data{$vendor}{$asset} }) {

                print $merge_out join("\t",
                    $vendor,
                    $lookup_value,
                    $asset,
                    $project_record->{project}
                ), "\n";
            }
        }
    }
}
exit;
