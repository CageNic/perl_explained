#!/usr/bin/perl
use strict;
use warnings;


while (<DATA>) {
	chomp $_;
	next if $. == 1;
	my ($id,$date1,$date2,$gender) = split(/,/,$_, -1);

	# strip any whitespace that could surround the F
	$gender =~ s/^\s+|\s+$//g;
	if (($date1 ge '1902-04-08' || $date1 eq "NA") &&
	    ($date2 le '1912-08-16' || $date2 eq "NA") && 
	     $gender eq "F") {
			print $_ , "\n";
		}
	}
exit;




__DATA__
id,date1,date2,gender
1,1900-02-02,NA,F
2,1902-04-08,1904-04-08,M
3,1908-10-22,NA,F
4,1910-12-04,1912-08-16,F
