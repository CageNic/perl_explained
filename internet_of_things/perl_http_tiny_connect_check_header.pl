#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;

my $http = HTTP::Tiny->new(verify_SSL => 0);
my $res = $http->head("https://ws.audioscrobbler.com");

if ($res->{success}) {
    print Dumper ($res->{headers}), "\n";
}

else {
    print "Failed: $res->{status} $res->{reason}\n";
}

############
# produces #
############

      'via' => '1.1 google',
          'accept-ranges' => 'bytes',
          'last-modified' => 'date' => 'Wed, day month year xx:xx:xx GMT',
          'content-length' => '151',
          'content-type' => 'text/html',
          'server' => 'openresty',
          'etag' => '"69e8b5f9-97"',
          'alt-svc' => 'h3=":443"; ma=2592000',
          'date' => 'date' => 'Wed, day month year xx:xx:xx GMT'
