################################################
# perl mechanize for extracting links examined #
################################################


# URI module is defining absolute urls and the host url in order to determine what is an internal and external url
# note that a $mech->content is not required as Mechanize will extract links without this needing to be declared
# It is not necessary to build an array of urls, you can loop over $mech->links directly

# $mech->links - urls that are not images
# why no images?
# because $mech->links checks <a href= >
# $mech->images checks <img src >

# can redirect the print output to a file from the command line and then use wget to download

###################################################################
# the difference between $mech->images and $mech->find_all_images #
####################################################################

# In WWW::Mechanize, both methods deal with images on the current page, but they behave quite differently:
$mech->images
    • Returns a list of image objects (specifically WWW::Mechanize::Image objects). 
    • By default, it only includes images that have a src attribute. 
    • It’s a simpler, older interface meant for quick access. 
# $mech->find_all_images
    • Returns a list of image objects matching criteria you specify. 
    • Accepts filters like tag, src_regex, alt, etc. 
    • More flexible and powerful—designed for searching and filtering images.
# In short:
    • images = “give me the basic list of images” 
    • find_all_images = “search for images that match these conditions” 
	
# If you need fine-grained control (e.g., only images with certain URLs or alt text), find_all_images is the better choice.
# You don’t have to pass anything to find_all_images - it works fine with no parameters

# Calling:
# my @imgs = $mech->find_all_images();
# will return all images on the page, much like $mech->images.

# So what’s the difference in that case?
    • With no arguments, find_all_images behaves very similarly to images. 
    • The key advantage is that find_all_images can take filters when you need them, while images cannot. 

#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize;
use URI;

my $mech = WWW::Mechanize->new();
$mech->get('www.example.com');

my $base_host = URI->new($mech->uri)->host;

# $mech->links - urls that are not images
# why no images?
# because $mech->links checks <a href= >
# $mech->images checks <img src >

#####################################
# check internal and external links #
# ###################################

foreach my $link ($mech->links) {
    my $url  = URI->new_abs($link->url, $mech->uri);
    my $host = $url->host;

    if ($host eq $base_host) {
        print "Internal: $url\n";
    }
     else {
        print "External: $url\n";
    }
}

##########################################
# check internal and external image urls #
##########################################

foreach my $img ($mech->images) {
	my $url  = URI->new_abs($img->url, $mech->uri);
        my $host = $url->host;

        if ($host eq $base_host) {
            print "Internal image: $url\n";
        }  
         else {
            print "External image: $url\n";
        }
exit;
}
exit;
