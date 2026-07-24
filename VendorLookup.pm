package VendorLookup;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(read_vendor_file);

sub read_vendor_file {
    my ($filename) = @_;

   my %hash;

open(my $in, '<', $filename) or die "Cannot open $filename: $!";

# Skip header line
my $header_row = <$in>;

while (my $line = <$in>) {
    chomp $line;
    $line =~ s/\r$//;

    my ($key, $value) = split (/\t/, $line);

    # remove parentheses and their contents from hash key
    $key =~ s/\([^)]*\)//g;

    # clean up any extra spaces
    $key =~ s/\s+/ /g;
    $key =~ s/^\s+|\s+$//g;

    # only active vendors
    next if $value eq "Archived";

    $hash{$key} = $value;
}
close $in;

    return \%hash;
}

1;