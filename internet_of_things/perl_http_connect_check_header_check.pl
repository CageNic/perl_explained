#####################################################################################
# check if a connection to last.fm can be made and if so, check the header response #
#####################################################################################

# ssl check set to false to get round any IT stuff

use strict;
use warnings;
use HTTP::Tiny;
use Data::Dumper;

my $http = HTTP::Tiny->new(verify_SSL => 0);
my $url  = "https://ws.audioscrobbler.com";

my $res = $http->get($url);

if ($res->{success}) {
    print "HTTPS works!\n";
    print Dumper($res) , "\n";
} else {
    print "Failed: $res->{status} $res->{reason}\n";
}

############
# produces #
############

HTTPS works!
$VAR1 = {
          'success' => !!1,
          'reason' => 'OK',
          'url' => 'https://ws.audioscrobbler.com',
          'protocol' => 'HTTP/1.1',
          'headers' => {
                         'content-type' => 'text/html',
                         'accept-ranges' => 'bytes',
                         'server' => 'openresty',
                         'etag' => '"69e8b5f9-97"',
                         'date' => 'Wed, day month year xx:xx:xx GMT',
                         'content-length' => '151',
                         'via' => '1.1 google',
                         'alt-svc' => 'h3=":443"; ma=2592000',
                         'last-modified' => 'Wed, day month year xx:xx:xx GMT'
                       },
          'content' => '<html><head>
<title>Last.fm API</title>
</head><body>
<p>Please visit <a href="https://www.last.fm/api">https://www.last.fm/api</a></p>
</body></html>
',
          'status' => '200'
        };

