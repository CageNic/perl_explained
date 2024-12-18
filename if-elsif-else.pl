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

############################################
# perl if AND OR with parentheses examined #
############################################

# both $age < 30 and $age > 10 must be satisfied

my $age = 22;

if ($age < 30 && $age > 10) {

   print qq{You're young, but no spring chicken\n};

}

# either $age < 13 or $age > 19 must be true in order that the specified statements be executed

my $age = 22;

if ($age < 13 || $age > 19) {

   print qq{You're not a teenager\n};

}

If you have multiple such conditions to test for, it is wise to group them using brackets:

my $age = 22;

my $gender = 'female';

if ($gender eq 'female' && ($age < 13 || $age > 19) ) {

   print qq{You're a female, but not a teenager\n};

}

Sometimes, it is more natural to express a condition as the negation of another condition.
For this, you can use the ! operator:

my $age = 22;

my $gender = 'female';

if ($gender eq 'female' && ! ($age > 12 && $age < 20) ) {

   print qq{You're a female, but not a teenager\n};

}

