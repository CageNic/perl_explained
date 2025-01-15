package CSVgrab;
use strict;
use warnings;
use Data::Dump qw(pp);
use Carp qw(croak);

our $VERSION = 0.01;

use base 'Exporter';
our @EXPORT_OK = qw(capture_csv pp croak);
our %EXPORT_TAGS = ( all => \@EXPORT_OK);

sub capture_csv {
  my $file = shift;
  croak unless $file;
  my @array;
  open (my $fh,'<',$file);
  while (my $lines = <$fh>) {
    chomp $lines;
    my $arr = [split /,/,$lines];
    
    my $hash = {
		'ID'    => $arr->[0],
		'greet' => $arr->[1],
                'extra' => $arr->[2]
               };
    push ( @array , $hash );
}
close $fh;
return \@array;
} 

1;  
  
