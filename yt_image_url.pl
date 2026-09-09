####################################
# get the image of a youtube video #
####################################

#!/usr/bin/env perl

use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP qw(decode_json);

my $channel_url = shift
    or die "Usage: $0 <youtube-channel-videos-url>\n";

my $http = HTTP::Tiny->new(
    agent      => 'Mozilla/5.0',
    verify_SSL => 0,
    timeout    => 30,
);

my $res = $http->get($channel_url);

die "HTTP error: $res->{status} $res->{reason}\n"
    unless $res->{success};

my $html = $res->{content};

$html =~ /(?:var ytInitialData = |"ytInitialData":)(\{.*?\});?(?:<\/script>|<\/body>)/s
    or die "ytInitialData not found\n";

my $data = decode_json($1);

my %seen;

walk($data);

sub walk {
    my ($node) = @_;

    return unless ref $node;

    if (ref($node) eq 'HASH') {

        if (exists $node->{videoId}) {

            my $id = $node->{videoId};

            if ($id =~ /^[A-Za-z0-9_-]{11}$/ && !$seen{$id}++) {

                my $title = '';

                if (exists $node->{title}{runs}[0]{text}) {
                    $title = $node->{title}{runs}[0]{text};
                }
                elsif (exists $node->{title}{simpleText}) {
                    $title = $node->{title}{simpleText};
                }

                # look one level up/down for title fields commonly used
                if (!$title && exists $node->{navigationEndpoint}) {
                    $title = 'unknown';
                }

                print "Title : $title\n";
                print "Video : https://www.youtube.com/watch?v=$id\n";
                print "Thumb : https://i.ytimg.com/vi/$id/maxresdefault.jpg\n\n";
            }
        }

        walk($_) for values %$node;
    }

    elsif (ref($node) eq 'ARRAY') {
        walk($_) for @$node;
    }
}
