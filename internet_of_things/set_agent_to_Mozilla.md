```# Without mimicking a browser, the website gave a 403```\
```# Adding Mozilla as the agent allowed download```
```
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

my $url = 'some/url'

 ##################
 # or this syntax #
 ##################

  my $browser = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 }, );
       my $agent = $browser->agent;
       $browser->agent('Mozilla/5.0');
       my $response = $browser->get($url);
# do stuff with $response
```

