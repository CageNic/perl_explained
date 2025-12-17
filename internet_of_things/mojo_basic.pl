#!/usr/bin/perl
use strict;
use warnings;
use Mojo::UserAgent;
use Mojo::DOM;
use feature 'say';

my $ua = Mojo::UserAgent->new;
my $saved_html = 'saved.html';
unless( -e $saved_html ) {
say "Fetching fresh HTML";
}
my $tx = $ua->get( 'https://www.mojolicious.org' );
unless( $tx->result->is_success ) {
die "Could not fetch! Error is ", $tx->result->code;
}

$tx->result->save_to( $saved_html );

my $data = Mojo::File->new( $saved_html )->slurp;
my $dom = Mojo::DOM->new($data);


# Extract and print title
my $title = $dom->at('article h1 a');
print "Title: $title\n";

# Extract and print post URL
my $url = $dom->at('article h1 a')->attr('href');
print "Post URL: $url\n";

# Extract and print the post content
my $content = $dom->at('.post-content');
print "Content: $content\n";

# Extract and print the image URL
my $image_url = $dom->at('figure img')->attr('src');
print "Image URL: $image_url\n";

# Extract and print post date
my $post_date = $dom->at('.post-meta time');
print "Post Date: $post_date\n";

# Extract and print comments count
my $comments_count = $dom->at('.post-meta .post-comments');
print "Comments: $comments_count\n";
