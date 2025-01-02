# get Simpsons episodes from the 90s
# and those with Homer in the title

#!/usr/bin/perl
use strict;
use warnings;
use Text::CSV;
use DateTime::Format::Strptime;
use Carp qw(croak);
use feature 'say';

my $format     = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d' );
my $start_date = DateTime->new(
                               year  => 1990, 
                               month => 01,
                               day   => 01, 
                               formatter => $format
                              );
my $end_date  = DateTime->new(
                              year  => 1999,
                              month => 12,
                              day   => 31,
                              formatter => $format
                             );

my $homer_pattern = qr/[Hh]omer/;

my $file = 'Simpsons_episode_summaries.csv';
croak "Could not locate file" unless -f $file ;

my $csv = Text::CSV->new( {binary => 1, sep_char => ','} );
croak "Cannot use CSV module" if $csv->error_diag();

open (my $in,'<',$file) or croak "Unable to open $file";
my $header = $csv->getline($in) ;
$csv->column_names( @{$header} ) ;

my $hash_ref ;
while ( $hash_ref = $csv->getline_hr($in) ) {
 
  # format the date in the csv file
 
  my $date = $format->parse_datetime( $hash_ref->{original_air_date} );
  $date->set_formatter($format);
  $format = $date->formatter();

  # boolean comparison operator for the dates
  # and a nested if for better readability
  # rather than add the search pattern
  # to another &&

  if ( $date > $start_date && $date < $end_date ) {
    if ($hash_ref->{title} =~ m/$homer_pattern/g) {
      say "$hash_ref->{title}\t$hash_ref->{original_air_date}\t$hash_ref->{season}";
    } 
  }
}
$csv->eof or $csv->error_diag();
close $in or croak "Cannot close $file";
