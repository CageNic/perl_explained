########################################
# perl count captured matches examined #
########################################

# capture the pattern on each line
# use g modifier to include pattern on line more than once
# create a count for match on each line
# create a total count

#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

my $total_count = 0;

while (<DATA>) {
  chomp $_;
  my @matches = $_ =~ m/(foo)/g;

  my $count = scalar (@matches);
  say "$1\t$count\t$_";

  $total_count += $count;
  }

say '';
say "total count for pattern in file: $total_count";

############
# produces #
############

foo     2       123foobarbazfoo
foo     1       foo
foo     1       foobarbaz
foo     4       foo foo foo foo
foo     0       no pattern here

total count for pattern in file: 8 

__DATA__
123foobarbazfoo
foo
foobarbaz
foo foo foo foo
no pattern here
