package VendorProjectAssetOutput;

# structures the data into vendor as key, asset as key, vendor as key

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    print_vendor_first
    print_project_first
    print_asset_first
);

sub print_record {
    my ($fh, $vendor, $project, $asset) = @_;

    print $fh join("\t",
        $vendor,
        $project,
        $asset
    ), "\n";
}


sub print_vendor_first {
    my ($data, $fh) = @_;

    for my $vendor (sort keys %$data) {
        for my $asset (sort keys %{ $data->{$vendor} }) {
            for my $project_record (@{ $data->{$vendor}{$asset} }) {

                print_record(
                    $fh,
                    $vendor,
                    $project_record->{project},
                    $asset
                );

            }
        }
    }
}


sub print_project_first {
    my ($data, $fh) = @_;

    for my $project (sort keys %$data) {
        for my $record (@{ $data->{$project} }) {

            print_record(
                $fh,
                $record->{vendor},
                $project,
                $record->{asset}
            );

        }
    }
}


sub print_asset_first {
    my ($data, $fh) = @_;

    for my $asset (sort keys %$data) {
        for my $record (@{ $data->{$asset} }) {

            print_record(
                $fh,
                $record->{vendor},
                $record->{project},
                $asset
            );

        }
    }
}

1;