# SDE Project Log report from OneTrust for file to read
# module VendorLookup and module AssetLookup in same directory as script
# module VendorLookup reads vendor status file from OneTrust - filtered for Active
# module AssetLookup reads asset status file from OneTrust - filtered for Active
# active projects is filtered in this script
# why this setup?
# need active projects - the SDE Project Log.txt file provides this info
# need active users - the SDE Project Log.txt file does not provide this info
# need active assets - the SDE Project Log.txt file does not provide this info
# so... VendorLookup reads vendor status.txt and filters on active vendors
#       AssetLookup reads asset status.txt and filters on active assets
# these are read as a hash, where key is the asset name and value is whether active or archived
# key is the vendor name and value is whether active or archived
# these are read into the main script and filters the main data structure from Project Status Log.txt to create new structures
# with active vendors assets and projects


#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use JSON qw(encode_json);
use lib '.';
use AssetLookup qw(read_asset_file);
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

# only archived projects filtered out at this stage from main script
# archived assets and vendors inlcuded
# check structure
# print Dumper(\%data);

open (my $dd,'>','OneTrust_vendor_asset_project_json_map.json');
my $json = JSON->new->pretty(1);
print $dd $json->encode(\%vendor_data);
close $dd;

my %asset_data;
my %project_data;
my %vendor_data_filtered;
my $hash_vendor = read_vendor_file("vendor status.txt");
my $hash_asset  = read_asset_file("asset status.txt");

# check that only active assets and vendors are included for new data structures
print Dumper ($hash_asset);
print "\n";
# print Dumper ($hash_vendor);

# create the data team structure so can be filtered out
my %exclude_vendor = map { $_ => 1 } (
    'Andrew Campbell',
    'Elizabeth Crellin',
    'Sophie Hodges',
    'Jay Hughes',
);

# filter on the active vendors and assets read from the modules and create new data structures for them

for my $vendor (sort keys %vendor_data) {
    # filter out the data team
    next if exists $exclude_vendor{$vendor};
    # only inlcude active vendors
    next unless exists $hash_vendor->{$vendor};
   
    for my $asset (sort keys %{ $vendor_data{$vendor} }) {
    # only include active assets
    next unless exists $hash_asset->{$asset};
        for my $project_record (@{ $vendor_data{$vendor}{$asset} }) {
             
            # create filtered vendor as outer key structure
            push @{ $vendor_data_filtered{$vendor}{$asset} }, $project_record;
            my $project = $project_record->{project};

            # create filtered project as outer key structure
            push @{ $project_data{$project} }, {
                vendor => $vendor,
                asset  => $asset,
            };

            # create filtered asset as outer key structure
            push @{ $asset_data{$asset} }, {
                vendor  => $vendor,
                project => $project,
            };
        }
    }
}

# open the files for outputs
open (my $vendor_out,  '>', "vendor_output_$file_date.txt") or die $!;
open (my $project_out, '>', "project_output_$file_date.txt") or die $!;
open (my $asset_out,   '>', "asset_output_$file_date.txt") or die $!;

# the subroutines and data structures to file outputs
print_vendor_first(\%vendor_data_filtered, $vendor_out);
print_project_first(\%project_data, $project_out);
print_asset_first(\%asset_data, $asset_out);

close $vendor_out;
close $project_out;
close $asset_out;

exit;