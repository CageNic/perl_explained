#!/usr/bin/perl
use strict;
use warnings;

open (my $fh,  '<', 'test.txt') ;
open (my $out, '>', 'output.txt') ;

my $header = <$fh>;
chomp $header;

my @header_fields = split(/,/, $header, -1);

print $out join(',', @header_fields), "\n";

my $expected_fields = scalar @header_fields;

my $error_file_handle;

while (my $lines = <$fh>) {
    chomp $lines;

    my @array = split(/,/, $lines, -1);

    if (scalar @array != $expected_fields) {

	      # First error encountered?
        if (!$error_file_handle) {

            # Create errorlog.txt and put its filehandle in $err.
            open($error_file_handle, '>', 'errorlog.txt')
                or die "Cannot open errorlog.txt: $!";
        }

        # Write this error to errorlog.txt.
        print $error_file_handle "Line $.: ",
                   scalar @array,
                   " fields - expected $expected_fields\n";
    }

    my $i = 0;

    while ($i <= $#array) {
        $array[$i] = 'NA' if $array[$i] eq '';
        $i++;
    }

    print $out join(',', @array), "\n";
}

close $fh;
close $out;
if ($error_file_handle) {
	print  "Error log created" , "\n";
}
  else {
	print "No error log created" , "\n";
}
exit;

# cat test.txt
# field1,field2,field3,field4
# A,,C,D
# A,B,C,D
# ,B,C,D
# A,B,C,,
# A,B,C,D,
# A,,,D
