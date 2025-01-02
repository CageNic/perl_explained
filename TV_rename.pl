# rename file to kodi format
# original file format - Name of TV Show Year SeasonEpisode-alphanumericstuffhere.mp4
# required output - Name of TV Show (Year) SeasonEpisode.mp4

#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use File::Copy;

# directory is working directory

my $dir = '.';
opendir (my $dh, $dir) or die "Could not open '$dir' for reading '$!'\n";
while (my $thing = readdir $dh) {
 next if $thing eq '.' or $thing eq '..';
 my $new_thing;
  if ($thing =~ m/\.mp4$/) {
	  my @array = split (/-/,$thing);
	  my @arr = split (/\s+/,$array[0]);
	  $new_thing = "$arr[0] $arr[1] ($arr[2]) $arr[3].mp4";
  }
 say "copying $thing to $new_thing";
 copy ($thing, $new_thing);
 }
closedir $dh;
