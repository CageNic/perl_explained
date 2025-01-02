#######################################
# get the paragraph text from website #
# #####################################

# need to add src to each paragraph for database
# create a loop in order to obtain each page
# # redirect output to a file where the title is the month and year

#!/usr/bin/perl
use strict;
use warnings;
use Mojo::UserAgent;

my $url = 'web address';
                   
my $ua = Mojo::UserAgent->new();
my $collection = $ua->get($url)->res->dom->find('div.entry-content > p')->map('text')->join("\n");
print $collection;
print "\n";
