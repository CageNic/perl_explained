# SDE Project Log report from OneTrust for file to read
# module VendorLookup and module AssetLookup in same directory as script
# module VendorLookup reads vendor status file from OneTrust - filtered for Active
# module AssetLookup reads asset status file from OneTrust - filtered for Active
# active projects is filtered in this script
# why this setup?
# need active projects - the SDE Project Log Perl.txt file provides this info
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

my $file = shift @ARGV or die "Usage: $0 SDE Project Log Perl.txt needed... download from OneTrust\n";

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
for my $required ('SDE Project ID', 'Name', 'Name - Related (Vendors)', 'Name - Related (Assets)', 'SDE Project Status', 'Status', 'SDE Project Start Date', 'SDE Project End Date') {
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

    # preserve empty trailing column with -1
    my @fields = split /\t/, $_, -1;

     my $project = $fields[$col{'SDE Project ID'}];
     my $name    = $fields[$col{'Name'}];
     my $vendors = $fields[$col{'Name - Related (Vendors)'}];
     my $assets  = $fields[$col{'Name - Related (Assets)'}];
     my $SDE_status  = $fields[$col{'SDE Project Status'}];
     my $status      = $fields[$col{'Status'}];
     my $start_date  = $fields[$col{'SDE Project Start Date'}];
     my $finish_date = $fields[$col{'SDE Project End Date'}];

    # remove surrounding quotes
    $vendors =~ s/^"(.*)"$/$1/;
    $assets  =~ s/^"(.*)"$/$1/;

    # populate undefined or empty values
    # vendor NA is a key... needs to be unique - therefore line number inlcuded to make unique
	
    $SDE_status  = 'no SDE status' if !defined($SDE_status) || $SDE_status eq '';
    $status  = 'no status' if !defined($status) || $status eq '';
    $vendors = "line $. in SDE Project Log - No vendor" if !defined($vendors) || $vendors eq '';
    $project = 'no project in SDE Project Log' if !defined($project) || $project eq '';
    $assets  = 'no asset in SDE Project Log' if !defined($assets)  || $assets eq '';
    $name    = 
    $start_date  =
    $finish_date =

    # do not inlcude archived projects
    # if $SDE_Status or $Status is undefined or an empty string - skip
    next if $SDE_status eq 'Archived' || $status eq 'Archived';

    print "$name\t$vendors\t$assets\t$SDE_status\t$status\t$start_date\t$finish_date\n";

 # }
   # get to the vendors which are a string - with comma separated delimiter for each vendor
    # split vendors
    my @vendor_list = split /\s*,\s*/, $vendors;

    # get to the assets which are a string - with comma separated delimiter for each asset
    # split assets
    my @asset_list = split /\s*,\s*/, $assets;
  
    # data structure

    # vendor
    #    |
    #    +-- Asset
    #           |
    #           +-- { project => ID }

for my $vendor (@vendor_list) {
    # normalize vendor name
    $vendor =~ s/\([^)]*\)//g;
    $vendor =~ s/\s+/ /g;
    $vendor =~ s/^\s+|\s+$//g;
  
        for my $asset (@asset_list) {
            # normalize asset name
            $asset =~ s/^\s+|\s+$//g;

            # Prevent duplicate vendor/asset/project
            my $unique_key = join('|', $vendor, $asset, $project);
            next if $seen{$unique_key};

            # store project and vendor as hash key and value inside an array
            # vendor = outer hash key
            # project - hash key, $asset - hash value inside an array
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
# print Dumper(\%vendor_data);

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
# print Dumper ($hash_asset);
# print "\n";
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

# test stuff
#print "vendor" , "\n";
#print Dumper(\%vendor_data_filtered) , "\n";
#print "project" , "\n";
#print Dumper(\%project_data) , "\n";
#print "asset" , "\n";
#print Dumper(\%asset_data) , "\n";

exit;