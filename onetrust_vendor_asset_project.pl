# SDE Project Log report from OneTrust for file to read
# module VendorLookup in same directory as script
# module VendorLookup reads vendor status file from OneTrust
# active projects
# if require both active and archived projects - comment out this code - next if $status ne 'Active';

#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use JSON qw(encode_json);
use lib '.';
use VendorLookup qw(read_vendor_file);
use VendorProjectAssetOutput qw(print_vendor_first print_project_first print_asset_first);

# timestamp for file output
my @t = localtime;
my $day = $t[3];
my $month = $t[4] + 1;
my $year  = $t[5] + 1900;

# format the date - need a leading 0 for days months that are not double digits
my $file_date = sprintf(
    "%02d-%02d-%04d",
    $t[3],        # day
    $t[4] + 1,    # month
    $t[5] + 1900  # year
);

# usage:
#   perl script.pl input_file.txt

my $file = shift @ARGV or die "Usage: $0 SDE Project Log.txt needed... download from OneTrust\n";

open (my $fh, '<', $file) or die "Cannot open $file: $!\n";

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

my %vendor_data;
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

    # Normalize vendor name
    $vendor =~ s/\([^)]*\)//g;
    $vendor =~ s/\s+/ /g;
    $vendor =~ s/^\s+|\s+$//g;
  
        for my $asset (@asset_list) {
            next unless $asset;
            $asset =~ s/^\s+|\s+$//g;

            # Prevent duplicate vendor/asset/project
            my $unique_key = join('|', $vendor, $asset, $project);
            next if $seen{$unique_key};

            # store project as an array element
            # project - hash key, $project - hash value
            push @{ $vendor_data{$vendor}{$asset} },
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

open (my $dd,'>','OneTrust_vendor_asset_project_json_map.json');
my $json = JSON->new->pretty(1);
print $dd $json->encode(\%vendor_data);
close $dd;

# from the vendor status report on OneTrust - merge the vendor with the vendor from the project report, but filter on active vendors
# have vendor as hash key, and status as hash value

my %asset_data;
my %project_data;
my %vendor_data_filtered;
my $hash = read_vendor_file("vendor status.txt");

# exclude the data team from outputs
my %exclude_vendor = map { $_ => 1 } (
    'Andrew Campbell',
    'Elizabeth Crellin',
    'Sophie Hodges',
    'Jay Hughes',
);

# Filter vendor_data to active vendors only
for my $vendor (sort keys %vendor_data) {
    next if exists $exclude_vendor{$vendor};
    next unless exists $hash->{$vendor};
    for my $asset (sort keys %{ $vendor_data{$vendor} }) {
        for my $project_record (@{ $vendor_data{$vendor}{$asset} }) {

            # create filtered vendor structure
            push @{ $vendor_data_filtered{$vendor}{$asset} }, $project_record;
            my $project = $project_record->{project};

            # create project as outer key
            push @{ $project_data{$project} }, {
                vendor => $vendor,
                asset  => $asset,
            };

            # create asset as outer key
            push @{ $asset_data{$asset} }, {
                vendor  => $vendor,
                project => $project,
            };
        }
    }
}

# print Dumper (\%project_data);
# print Dumper (\%asset_data);

open (my $vendor_out,  '>', "vendor_output_$file_date.txt") or die $!;
open (my $project_out, '>', "project_output_$file_date.txt") or die $!;
open (my $asset_out,   '>', "asset_output_$file_date.txt") or die $!;

print_vendor_first(\%vendor_data_filtered, $vendor_out);
print_project_first(\%project_data, $project_out);
print_asset_first(\%asset_data, $asset_out);

close $vendor_out;
close $project_out;
close $asset_out;