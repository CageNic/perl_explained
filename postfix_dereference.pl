#######################################
# perl postfix dereferencing examined #
#######################################

# needs v5.20 or higher
# this script uses perlbrew and v5.27
# no need for - use feature qw(postderef)
# as would be needed in v5.20

#!/usr/bin/env/perl
use strict;
use warnings;
use feature 'say';

# create an array of hashes data structure

my $addresses = [
  { 'name'    => 'John Doe',
    'address' => '123 Any Street',
    'city'    => 'Anytown',
    'state'   => 'TX',
  },
  { 'name'    => 'Mary Smith',
    'address' => '100 Other Avenue',
    'city'    => 'Whateverville',
    'state'   => 'PA',
  },
];

# print the name from the first array element

#-------------------------------------------------------#
# non-traditional way of dereferencing not using arrows #
#-------------------------------------------------------#

say $$addresses[0]{'name'};

# prints John Doe

#-----------------------------------------------#
# traditional way of dereferencing using arrows #
#-----------------------------------------------#

say $addresses->[0]->{'name'};

# prints John Doe

#########################################
# looping without postfix dereferencing #
#########################################

# getting all the names

foreach my $element (@{$addresses}) {
  say $element->{name};
}
 
#########################
# postfix dereferencing #
#########################

# makes it easier to get slices from specific element

# getting a slice from 1st array element

say for $addresses->[0]->@{'name', 'city'};

#--------------------#
# a slice of a slice #
#--------------------#

# getting a slice from several array elemenets

say for $addresses->[ 0, 1 ]->@{ qw(name city) };
