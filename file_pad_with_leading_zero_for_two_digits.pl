Here is a Perl script that opens a directory, uses readdir to read its contents, and copies each .aac file to a new filename with a leading zero for single-digit track numbers. The original files remain untouched.

For example:

    1 Thompson title.aac → creates 01 Thompson title.aac
    2 Thompson title.aac → creates 02 Thompson title.aac
    9 Thompson title.aac → creates 09 Thompson title.aac
    10 Thompson title.aac → unchanged; no copy needed.

Perl script to copy and zero-pad track numbers
perl

#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use File::Copy qw(copy);

# Directory containing the music files
my $dir = shift // '.';

# Open the directory
opendir(my $dh, $dir)
    or die "Cannot open directory '$dir': $!\n";

# Read directory entries
while (my $file = readdir($dh)) {

    # Match filenames beginning with a track number followed by a space
    next unless $file =~ /^(\d+) (.+\.aac)$/i;

    my $track = $1;
    my $rest  = $2;

    # Skip track numbers that already have two or more digits
    next if length($track) >= 2;

    # Build the new filename
    my $newfile = sprintf("%02d %s", $track, $rest);

    # Construct full paths
    my $source = File::Spec->catfile($dir, $file);
    my $target = File::Spec->catfile($dir, $newfile);

    # Skip if the destination already exists
    if (-e $target) {
        print "SKIP: $newfile already exists\n";
        next;
    }

    # Copy the original to the new filename
    if (copy($source, $target)) {
        print "COPIED: $file -> $newfile\n";
    }
    else {
        warn "ERROR copying '$file': $!\n";
    }
}

closedir($dh);

print "Finished.\n";

How to run it

    Save the script as pad_tracks.pl.
    Open a terminal.
    Run it against your music directory:

bash

perl pad_tracks.pl "/path/to/your/music"

Alternatively, omit the directory argument to process the current directory:
bash

perl pad_tracks.pl

Example output
text

COPIED: 1 Thompson title.aac -> 01 Thompson title.aac
COPIED: 2 Thompson title.aac -> 02 Thompson title.aac
COPIED: 3 Thompson title.aac -> 03 Thompson title.aac
SKIP: 09 Thompson title.aac already exists
Finished.

Important details

    Originals are preserved: The script uses copy(), not rename().
    Existing files are protected: It skips a copy if the destination already exists.
    Only .aac files are processed: The extension match is case-insensitive.
    Other filenames are ignored: Files that don't begin with a number followed by a space are skipped.
    The directory is configurable: Supply the directory path as the first command-line argument.

One subtle point: readdir doesn't guarantee the order in which files are processed. That doesn't affect the results because the script constructs each destination filename independently.
