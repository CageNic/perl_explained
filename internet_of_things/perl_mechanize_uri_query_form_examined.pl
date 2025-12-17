######################################################################
# perl Mechanize with URI to identify all image links from a website #
# that include links outside the website domain                      #
# prints urls to file for use with wget or other applications        #
######################################################################

# uses URI query_form (although mechanize also has this function)
# URI legislates for an address such as https://www.webaddress/subject/?page=2 etc.
# so no need to enter the ? and = in the address
# the query_form does this

use strict;
use warnings;
use WWW::Mechanize;
use URI;

# 1. Create Mechanize object
my $mech = WWW::Mechanize->new(
    agent => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/117.0.0.0 Safari/537.36",
    autocheck => 1,
);

my @images;

my $base_url = "https://www.webaddress.com";
my $uri = URI->new($base_url);
print $uri , "\n";

# Loop over pages
for my $page_num (1..100) {
    $uri->path("/subject/");
    $uri->query_form( page => $page_num);
    print $uri , "\n";
    $mech->get($uri);
    @images = $mech->find_all_images();
}

open (my $fh, '>', 'links.txt') or die "Cannot open file: $!", "\n";
for my $img (@images) {
    my $img_url = URI->new_abs($img->url, $uri);
    print $fh $img_url , "\n";
}
close $fh;

print "Found ", scalar(@images), " images.\n";
