#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;

my $http = HTTP::Tiny->new(verify_SSL => 0);
# my $res = $http->head("https://e.pcloud.link/publink/show?code=XZ2oaGZEdotQG9acbLH6fRjPOXluQwKaD47");
my $res = $http->head("https://elon1.pcloud.com/cBZo0g7diZ5PQQfE7ZZZtsXu5kZ2ZZqg0ZkZXKfNKLZM4Z6LZfPZXPZ5LZhFZG8ZZWLZy5ZiLZDVZKJZEkZ2oaGZN6UDYhu7OfL44x7hmmYkD0k5D8iy/IMPACTncd_Engl_31032026.zip");

if ($res->{success}) {
    print Dumper ($res->{headers}), "\n";
}

else {
    print "Failed: $res->{status} $res->{reason}\n";
}
