#####################################################################
# traverse current working directory and find sub folders and files #
#####################################################################

# reports on file size and line count per file

#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::stat;

my $file_count = 0;          # To keep track of the number of files
my $dir_count = 0;           # To keep track of the number of directories
my $total_size = 0;          # To accumulate the total size of files

# Function to process each file or directory
sub process_file {
    my $path = $File::Find::name;

    # If it's a directory, increment the directory count
    if (-d $path) {
        # Skip "." (current directory) and ".." (parent directory)
        if ($path ne '.' && $path ne '..') {
            $dir_count++;
        }
        return;  # No need to process directories further for file-related info
    }

    # Skip if it's not a file (directories, symlinks, etc.)
    return if not -f $path;

    # Check if the file is readable
    if (-r $path) {
        # Get file size in bytes
        my $size = -s $path;
        $total_size += $size;

        # Get the number of lines in the file
        open my $fh, '<', $path or die "Cannot open file $path: $!\n";
        my $line_count = 0;
        $line_count++ while <$fh>;
        close $fh;

        # Increment the total file count
        $file_count++;

        # Print details about the file
        print "File: $path\n";
        print "  Size: $size bytes\n";
        print "  Line count: $line_count lines\n\n";
    } else {
        print "File: $path is not readable.\n\n";
    }
}

# Use File::Find to traverse the directory tree starting from the current directory
find({ wanted => \&process_file, no_chdir => 1 }, ".");

# Print the total file and directory count
print "Total number of readable files: $file_count\n";
print "Total number of directories: $dir_count\n";
print "Total size of all files: $total_size bytes\n";

#######################################################################
# this is for just files in current working directory and sub folders #
#######################################################################

# Perl script that checks files in directory and sub directories, reports on their size and lines
# Then a collective file count and collective file size

# run on command line with perl name_of_this_script.pl stdb -oL > fileout.txt

#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::stat;

my $file_count = 0;
my $total_size = 0;

sub process_file {
	my $file = $File::Find::name;
	return if !-f $file;
	
	if (-r $file) {
	my $size = -s $file;
	$total_size += $size;
	
	open (my $fh ,'<', $file) or die $!;
	my $line_count = 0;
	$line_count++ while <$fh>;
	close $fh;
	

	$file_count++;
	
	print "$file\t$size bytes\tLines\t$line_count\n";
	}
	
	else {
			print "File: $file is not readable\n";
			}
		}
	
	find ({wanted => \&process_file, no_chdir => 1}, ".");
	

print "Total readable files: $file_count\n";
print "Total size of all files: $total_size bytes\n";

exit;
