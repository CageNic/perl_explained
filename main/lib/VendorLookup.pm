package VendorLookup;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(read_vendor_file);

sub read_vendor_file {
    my ($filename) = @_;
    my %vendor_status;

open(my $in, '<', $filename) or die "Cannot open $filename: $!";

# Skip header line
my $header_row = <$in>;

while (my $line = <$in>) {
    chomp $line;
    $line =~ s/\r$//;

    my ($key, $value, $notes, $contact) = split (/\t/, $line);

    # remove parentheses and their contents from hash key
    $key =~ s/\([^)]*\)//g;

    # clean up any extra spaces
    $key =~ s/\s+/ /g;
    $key =~ s/^\s+|\s+$//g;

    # only active vendors
    next if $value eq "Archived";

    $vendor_status{$key} = $value;
}
close $in;

    return \%vendor_status
}

1;