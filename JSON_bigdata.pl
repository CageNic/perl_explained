###################################
# Perl LWP::UserAgent content_ref #
##################################

#################################################################################
# creating a Perl data structure within the while loop (reading in content_ref) #
#################################################################################

# dealing with a json string
# Dumper creates a singular $VAR inside the while loop

#!/usr/bin/perl
use strict ;
use warnings ;
use LWP::UserAgent ;
use JSON ;
use Data::Dumper ;

# the real bearer is long - hence concatenation for readability
my $bearer = "aaaa"
."bbbb"
."cccc"
."dddd"
."eeee"
."ffff"
."gggg" ;

my $ua = LWP::UserAgent->new();

sub downloader {
my ($url) = @_ ;
my $resp = $ua->get( $url,'Authorization' => "Bearer $bearer" );
die "Can't get data from api" , $resp->status_line unless $resp->is_success ;
my $message = $resp->decoded_content ;
return $message ;
}

my project = 1234 ;

# get the question keys (API keys) to an array

my $url = "https://webservices.somewhere.net/coder/Questions/$project?types=os" ;
my $json = downloader($url) ;
my $data = decode_json($json);

# push the API question keys onto @QIDs

my $QIDs = [] ;
foreach my $key (keys %{$data}) {
 foreach my $question (@{$data->{$key}}) {
  push (@{$QIDs},$question->{key}) ;
  } 
 }

# each question key in (@QIDs) is looped through to obtain full data that is held in the "Responses" API endpoint
# full data is held in a hash of array of hashes
# and is pushed to the outerkey (the question key)

my $hoaoh = {} ;
while (@{$QIDs}) {
	
 # empty the array an element at a time
 # and utilize $question as the outer hash key - with push
 
 my $question = shift (@{$QIDs}) ;
 my $resp = $ua->get("https://webservices.somewhere.net/coder/Responses/$question?includeText=True",'Authorization' => "Bearer $bearer") ;
 die "Can't get data from api" , $resp->status_line unless $resp->is_success ;
 open (my $fh, '<', $resp->content_ref) or die "Cannot write to scalar file: $!" ;
 open (my $out,'>',"outfile.txt") or die "Cannot write to output file: $!" ;
 while (<$fh>) {
 my $json = decode_json($_) ;
 push (@{$hoaoh->{$question}}, @{$json->{responses}} ) ;
 print $out Dumper ($hoaoh) ;
 }
close $fh ;
close $out ;
}
exit ;
