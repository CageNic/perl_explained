###########################
# last fm - recent tracks # 
###########################

#########################

# set these on the command line (only for the shell session)...

export LASTFM_USERNAME="your_api_key_here"
export LASTFM_API_KEY="your_user_name"

# close the shell session or use this on the command line when completed

unset "$LASTFM_API_KEY"
unset "$LASTFM_USERNAME"

########################

use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $API_KEY  = $ENV{LASTFM_API_KEY}  or die "Missing LASTFM_API_KEY";
my $USERNAME = $ENV{LASTFM_USERNAME} or die "Missing LASTFM_USERNAME";

my $http = HTTP::Tiny->new(verify_SSL => 0);  # SSL verification disabled temporarily

# set a limit for the return - 
my $limit = 10;

my $url = "https://ws.audioscrobbler.com/2.0/"
        . "?method=user.getrecenttracks&user=$USERNAME&api_key=$API_KEY&format=json&limit=$limit";

my $res = $http->get($url);

if ($res->{success}) {
    my $data = decode_json($res->{content});
    my $tracks = $data->{recenttracks}->{track};

    for my $t (@$tracks) {
        my $artist = $t->{artist}->{'#text'};
        my $title  = $t->{name};
        my $now_playing = $t->{'@attr'}->{nowplaying} // 0;
        print "$artist – $title (Now playing: $now_playing)\n";
    }
} else {
    die "HTTP GET failed: $res->{status} $res->{reason}\n";
}
