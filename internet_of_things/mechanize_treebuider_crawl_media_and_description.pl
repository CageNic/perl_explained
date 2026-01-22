##################################################
# recursive crawler in Perl using WWW::Mechanize #
##################################################

• Crawls pages recursively (depth-limited)
• Stays within the same domain
• Extracts images + audio
• Collects descriptions (alt, title, captions, surrounding text)
• Avoids revisiting pages

Recursive Media Crawler (Perl)

#!/usr/bin/perl
use strict;
use warnings;
use WWW::Mechanize;
use HTML::TreeBuilder;
use URI;

# ---------------- CONFIG ----------------
my $START_URL = shift or die "Usage: $0 <url> [depth]\n";
my $MAX_DEPTH = shift // 2;
# ----------------------------------------

my %visited;
my $mech = WWW::Mechanize->new(
    autocheck => 0,
    agent     => 'RecursiveMediaCrawler/1.0'
);

my $start_uri = URI->new($START_URL);
my $domain    = $start_uri->host;

crawl($START_URL, 0);

sub crawl {
    my ($url, $depth) = @_;
    return if $depth > $MAX_DEPTH;
    return if $visited{$url}++;

    print "\n== Crawling [$depth]: $url ==\n";

    eval { $mech->get($url); };
    return if $@ || !$mech->success;

    my $tree = HTML::TreeBuilder->new;
    $tree->parse($mech->content);
    $tree->eof;

    my $base = URI->new($url);

    extract_images($tree, $base);
    extract_audio($tree, $base);

    # Follow links
    for my $link ($mech->links) {
        next unless $link->url;

        my $abs = URI->new_abs($link->url, $base);
        next unless $abs->scheme =~ /^https?$/;

        # stay on same domain
        next unless ($abs->host // '') eq $domain;

        crawl($abs->as_string, $depth + 1);
    }

    $tree->delete;
}

sub extract_images {
    my ($tree, $base) = @_;

    for my $img ($tree->look_down(_tag => 'img')) {
        my $src = $img->attr('src') or next;

        my $url   = URI->new_abs($src, $base)->as_string;
        my $alt   = $img->attr('alt')   // '';
        my $title = $img->attr('title') // '';

        my $desc = extract_context($img);

        print "[IMAGE]\n";
        print " URL   : $url\n";
        print " ALT   : $alt\n"   if $alt;
        print " TITLE : $title\n" if $title;
        print " DESC  : $desc\n"  if $desc;
        print "-" x 50 . "\n";
    }
}

sub extract_audio {
    my ($tree, $base) = @_;

    # HTML5 <audio>
    for my $audio ($tree->look_down(_tag => 'audio')) {
        my $src = $audio->attr('src');

        if (!$src) {
            my ($source) = $audio->look_down(_tag => 'source');
            $src = $source ? $source->attr('src') : undef;
        }

        next unless $src;

        my $url   = URI->new_abs($src, $base)->as_string;
        my $title = $audio->attr('title') // '';
        my $desc  = extract_context($audio);

        print "[AUDIO]\n";
        print " URL   : $url\n";
        print " TITLE : $title\n" if $title;
        print " DESC  : $desc\n"  if $desc;
        print "-" x 50 . "\n";
    }

    # Direct audio file links
    for my $link ($mech->links) {
        next unless $link->url =~ /\.(mp3|wav|ogg|m4a)$/i;

        my $url  = URI->new_abs($link->url, $base)->as_string;
        my $text = $link->text // '';

        print "[AUDIO LINK]\n";
        print " URL  : $url\n";
        print " TEXT : $text\n" if $text;
        print "-" x 50 . "\n";
    }
}

sub extract_context {
    my ($node) = @_;
    my $parent = $node->parent or return '';

    my $text = $parent->as_text;
    $text =~ s/\s+/ /g;
    return substr($text, 0, 300); # limit size
}
