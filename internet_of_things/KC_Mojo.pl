# note that March 2022 sees a new web address
# https://xxxx.com


######################################################################
# perl LWP::UserAgent ealing with updated ssl certificate on website #
######################################################################

# KC website changed / updated SSL certificate
# no need to update open ssl on Ubuntu
# just ensure Net::SSL module is installed
# and ensure verify the ssl hostname is set to false

# 2 ways to do this

#!/usr/bin/perl
use strict;
use warnings;
use Mojo::DOM;
use LWP::UserAgent ;
use File::Basename qw(basename) ;
use Net::SSL;

#######################
# can use this syntax #
#######################

# $ENV{HTTPS_VERSION} = 3;
# $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

##################
# or this syntax #
##################
    
my $browser = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 }, );

###################

my $August_2023 = 'https://xxxx.com/year/month/page';

my $base_dir = "KC";

mkdir ("$base_dir/") unless -d ("$base_dir");

chdir "$base_dir" or die "Need to move into directory";
                   
sub downloader {
	
	my ($url) = @_;
	my $response = $browser->get($url);
	
	die "can't get url " , $response->status_line unless $response->is_success ;
	my $dom = Mojo::DOM->new($response->content);
	my $imageNodes = $dom->find('img');
	
	# need to work text in to accompanying files
	
	# my $textNodes  = $dom->find('p');
	# my @paragraph = $textNodes->map('text')->each;
	
	my @images = $imageNodes->map(attr => 'src')->each;
	
	foreach my $image (@images) {
		$browser->mirror($image,basename $image);
		$browser->show_progress(1);
		}
}

# infinite loop
for (my $x = 0; ; $x++) {
	downloader("$August_2023/$x");
}
