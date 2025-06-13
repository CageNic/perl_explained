###################################################################################################
# Perl script that checks files in directory and sub directories, reports on their size and lines #
# Then a collective file count and collective file size                                           #
# Reads inside zip files                                                                          #
# counts file extensions that are defined                                                         #
###################################################################################################

# run on command line with perl name_of_this_script.pl stdb -oL > fileout.txt

#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use File::stat;
use Data::Dumper;

my $file_count = 0;
my $total_size = 0;

sub get_extension {
	my ($filename) = @_;
	if ($filename =~ /(\.[^.]+)$/) {
		return $1;
	}
	
	# no extension
	return '';

}

my %extension_counts;



sub process_file {
	my $file = $File::Find::name;
	return if !-f $file;
	
	if (-r $file) {
	my $size = -s $file;
	$total_size += $size;
	
	open (my $fh ,'<', $file) or die $!;
	my $line_count = 0;
	$line_count++ while <$fh>;
	my $extension = get_extension($file);
	
	if ($extension =~ /\.csv$/ or $extension =~ /\.txt$/ or $extension =~ /\.xlsx$/ or $extension =~ /\.parquet$/ or $extension =~ /\.sas7bdat$/ or $extension =~ /\.egp$/ or $extension =~ /\.zip$/ or $extension =~ /\.R$/) {
		$extension_counts{$extension}++;
	}
		
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

print Dumper (\%extension_counts);
print "\n";

exit;
