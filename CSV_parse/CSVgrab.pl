#################################################
# array of hashes from csv in module subroutine #
#################################################

# module and script in same dir - no namespace

#!/usr/bin/perl
use strict;
use warnings;
use CSVgrab qw(pp croak capture_csv);

pp capture_csv('test_send_me_to_a_sub.csv'); 

exit;

# cat test_send_me_to_a_sub.csv
# 1,hello,hi
# 2,ciao,ola
# 3,bonjour,fr
# 4,great,usa
