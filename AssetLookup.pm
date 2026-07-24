package AssetLookup;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(read_asset_file);

sub read_asset_file {
    my ($filename) = @_;

   my %hash;

open(my $in, '<', $filename) or die "Cannot open $filename: $!";

# Skip header line
my $header_row = <$in>;

while (my $line = <$in>) {
    chomp $line;
    $line =~ s/\r$//;

    my ($key, $value) = split (/\t/, $line);

  # remove surrounding quotes
   $key  =~ s/^"(.*)"$/$1/;

    # only active assets
    next if $value eq "Archived";

    $hash{$key} = $value;
    
}
close $in;
    return \%hash;
}
1;

