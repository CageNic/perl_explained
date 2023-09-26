# if 2nd column exists and either 3rd column does or does not exist
# then the 2nd column is the value to take

# else if the 3rd column exists and the 2nd column does not exist
# then the 3rd column is the value to take

# else neither column has a value - the value is a printed statement


#!/usr/bin/perl
use strict;
use warnings;

my $file = "test.txt";
open (my $fh, '<', $file) or die $!;
my $header = <$fh>;
chomp $header;
while (my $lines = <$fh>) {
  chomp $lines;
  my $date;
  my $array_ref = [ split (/,/,$lines) ];
  if ( $array_ref->[3] && ($array_ref->[4] || !$array_ref->[4]) ) {
	  $date = $array_ref->[3];
  }
  elsif ( $array_ref->[4] && !$array_ref->[3] ) {
	  $date = $array_ref->[4];
  }
  else {
	  $date = "Date unkown - not in either column";
  }
  print $date , "\n";
}
close $fh;
