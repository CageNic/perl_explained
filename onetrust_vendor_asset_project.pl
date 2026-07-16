# SDE Project Log report from OneTrust for file to read
# to do - get a OneTrust vendor report... read it, skip archived vendors, map it to the vendor, asset, project data structure in this script, so that an output is as the main output of vendor, asset, project is for active vendors

#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

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
#
#             {
#                 project => 'project_id_2'
#             }
#
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

# map column names to positions
my %col;

for my $i (0 .. $#headers) {
    $col{$headers[$i]} = $i;
}

# Check required columns exist
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

    # if vendor has no asset - create a no asset value
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
            my $unique_key =
                join('|',
                    $vendor,
                    $asset,
                    $project
                );

            next if $seen{$unique_key};

            # store project as an array element
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

local $Data::Dumper::Terse = 1;
open (my $dd,'>','OneTrust_vendor_asset_project_hash_map.txt');
print $dd Dumper (\%data);
close $dd;

# print 3-column tab delimited file

# columns
#   Vendor    Asset    Project

# a vendor will repeat where an asset has multiple projects

open (my $out,'>','OneTrust_vendor_asset_project_map.txt');
print $out "Vendor\tAsset\tProject\n";

for my $vendor (sort keys %data) {
    for my $asset (sort keys %{ $data{$vendor} }) {
        for my $project_record (
            @{ $data{$vendor}{$asset} }
        ) {
            print $out join("\t",
                $vendor,
                $asset,
                $project_record->{project}
            ), "\n";
        }
    }
}
close $out;
exit;