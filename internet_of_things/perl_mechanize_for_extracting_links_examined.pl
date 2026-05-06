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
}
exit;
