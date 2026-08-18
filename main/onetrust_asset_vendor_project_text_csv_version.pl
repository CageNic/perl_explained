#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use JSON::PP;
use lib 'lib';
use Text::CSV;
use AssetLookup qw(read_asset_file);
use VendorLookup qw(read_vendor_file);
use VendorProjectAssetOutput qw(print_vendor_first print_project_first print_asset_first);

my @t = localtime;
my $file_date = sprintf(
    "%02d-%02d-%04d",
    $t[3],
    $t[4] + 1,
    $t[5] + 1900
);

my $file = shift @ARGV or die "Usage: needs SDE Project Log Perl.txt\n";

open(my $fh, '<', $file) or die "Cannot open $file: $!\n";

my $csv = Text::CSV->new({
    binary    => 1,
    sep_char  => "\t",
    auto_diag => 1,
});

my $headers = $csv->getline($fh) or die "Cannot read header row\n";

for (@$headers) {
    s/^\s+|\s+$//g;
}

my %col;
@col{@$headers} = (0 .. $#$headers);

for my $required (
    'SDE Project ID',
    'Name',
    'Name - Related (Vendors)',
    'Name - Related (Assets)',
    'SDE Project Status',
    'Status',
    'SDE Project Start Date',
    'SDE Project End Date'
) {
    die "Missing column: $required\n"
        unless exists $col{$required};
}

my %vendor_data;
my %seen;

while (my $fields = $csv->getline($fh)) {

    my $project     = $fields->[$col{'SDE Project ID'}];
    my $name        = $fields->[$col{'Name'}];
    my $vendors     = $fields->[$col{'Name - Related (Vendors)'}];
    my $assets      = $fields->[$col{'Name - Related (Assets)'}];
    my $SDE_status  = $fields->[$col{'SDE Project Status'}];
    my $status      = $fields->[$col{'Status'}];
    my $start_date  = $fields->[$col{'SDE Project Start Date'}];
    my $finish_date = $fields->[$col{'SDE Project End Date'}];

    $SDE_status = 'no SDE status' if !defined($SDE_status) || $SDE_status eq '';
    $status     = 'no status' if !defined($status) || $status eq '';
    $vendors    = "line $. in SDE Project file - No vendor" if !defined($vendors) || $vendors eq '';
    $assets  = 'No asset' if !defined($assets) || $assets eq '';
    $project = 'No project' if !defined($project) || $project eq '';
    $name    = 'No name' if !defined($name) || $name eq '';
    $start_date = 'No date' if !defined($start_date) || $start_date eq '';
    $finish_date = 'No date' if !defined($finish_date) || $finish_date eq '';


    next if $SDE_status eq 'Archived' || $status eq 'Archived';

    my @vendor_list = split /\s*,\s*/, $vendors;

    my @asset_list = split /\s*,\s*/, $assets;

    for my $vendor (@vendor_list) {
        $vendor =~ s/\([^)]*\)//g;
        $vendor =~ s/\s+/ /g;
        $vendor =~ s/^\s+|\s+$//g;

        for my $asset (@asset_list) {
            $asset =~ s/^\s+|\s+$//g;

            my $unique_key =
                join('|', $vendor, $asset, $project);

            next if $seen{$unique_key};

            push @{ $vendor_data{$vendor}{$asset} },
                {
                    project => $project
                };

            $seen{$unique_key} = 1;
        }
    }
}

close $fh;

open(my $json_out, '>',
    'OneTrust_vendor_asset_project_json_map.json')
    or die $!;

my $json = JSON::PP->new()->pretty(1);

print $json_out
    $json->encode(\%vendor_data);
close $json_out;

my $hash_vendor = read_vendor_file("vendor status.txt");
my $hash_asset = read_asset_file("asset status.txt");

my %exclude_vendor = map {$_ => 1} ('Andrew Campbell', 'Elizabeth Crellin', 'Sophie Hodges', 'Jay Hughes');

my %asset_data;
my %project_data;
my %vendor_data_filtered;

for my $vendor (sort keys %vendor_data) {
    next if exists $exclude_vendor{$vendor};
    next unless exists $hash_vendor->{$vendor};
    for my $asset (sort keys %{ $vendor_data{$vendor} }) {
        next unless exists $hash_asset->{$asset};
        for my $project_record
            (@{ $vendor_data{$vendor}{$asset} }) {

            push @{ $vendor_data_filtered{$vendor}{$asset} },
                $project_record;

            my $project =
                $project_record->{project};

            push @{ $project_data{$project} },
                {
                    vendor => $vendor,
                    asset  => $asset,
                };

            push @{ $asset_data{$asset} },
                {
                    vendor  => $vendor,
                    project => $project,
                };
        }
    }
}

open(my $vendor_out, '>', "vendor_output_$file_date.txt") or die $!;
open(my $project_out, '>', "project_output_$file_date.txt") or die $!;
open(my $asset_out, '>', "asset_output_$file_date.txt") or die $!;

print_vendor_first(\%vendor_data_filtered,$vendor_out);
print_project_first(\%project_data,$project_out);
print_asset_first(\%asset_data,$asset_out);

close $vendor_out;
close $project_out;
close $asset_out;

exit;