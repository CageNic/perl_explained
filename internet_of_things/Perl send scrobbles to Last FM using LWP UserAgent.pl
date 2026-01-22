######################################################
# Perl send scrobbles to Last FM using LWP UserAgent #
######################################################

# A Perl script that can send (“push”) track scrobble data to Last.fm’s Scrobble API, using a hash (e.g., %track = # ( artist => ..., track => ..., album => ... )) as input.

# scrobbling requires authentication and signing requests.

# Background
Last.fm’s Scrobble API endpoint is:

POST https://ws.audioscrobbler.com/2.0/
Method: track.scrobble
Auth: API key + API secret + session key
Format: application/x-www-form-urlencoded

# Prerequisites
# You’ll need:

# API key and API secret from https://www.last.fm/api/account/create

# Session key (obtained once using user authentication with auth.getSession)

# Store them in environment variables or directly in your script for testing:

export LASTFM_API_KEY="your_api_key"
export LASTFM_SECRET="your_secret"
export LASTFM_SESSION_KEY="your_session_key"

# Example Perl script — scrobble.pl
# Here’s a working example:

#!/usr/bin/perl
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use URI::Escape;

# --- Config ---
my $api_key    = $ENV{LASTFM_API_KEY}    || 'YOUR_API_KEY';
my $api_secret = $ENV{LASTFM_SECRET}     || 'YOUR_SECRET';
my $session_key = $ENV{LASTFM_SESSION_KEY} || 'YOUR_SESSION_KEY';
my $endpoint   = 'https://ws.audioscrobbler.com/2.0/';

# --- Track data hash ---
my %track = (
    artist => 'Radiohead',
    track  => 'Everything In Its Right Place',
    album  => 'Kid A',
    timestamp => time - 120,  # when the track was played (UNIX time)
);

# --- Build parameters ---
my %params = (
    method      => 'track.scrobble',
    api_key     => $api_key,
    sk          => $session_key,
    'artist[0]' => $track{artist},
    'track[0]'  => $track{track},
    'album[0]'  => $track{album},
    'timestamp[0]' => $track{timestamp},
);

# --- Generate API signature ---
# Signature = md5 of all params sorted alphabetically + secret
my $sig_string = join('', map { $_ . $params{$_} } sort keys %params) . $api_secret;
$params{api_sig} = md5_hex($sig_string);

$params{format} = 'json';

# --- Send request ---
my $ua = LWP::UserAgent->new;
my $response = $ua->post($endpoint, \%params);

if ($response->is_success) {
    print "✅ Scrobble successful:\n" . $response->decoded_content . "\n";
} else {
    print "❌ Scrobble failed: " . $response->status_line . "\n";
    print $response->decoded_content . "\n";
}

# run it
perl scrobble.pl
Expected output (if authentication is correct):

{"scrobbles":{"@attr":{"accepted":"1","ignored":"0"},"scrobble":[{"track":"Everything In Its Right Place","artist":"Radiohead", ...}]}}

# Notes
# You can push multiple tracks by adding [1], [2], etc. keys (e.g. 'artist[1]' => 'Muse').

# The timestamp must be within the past 14 days or Last.fm will reject it.

# If you get an authentication error, your session key might be expired or missing.

# a Perl script that reads multiple scrobbles (each as a hash) from a file or array and sends them to Last.fm in one API call (batch scrobble).

🔹 batch_scrobble.pl
#!/usr/bin/perl
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use JSON;

# ===============================
# CONFIGURATION
# ===============================
my $api_key     = $ENV{LASTFM_API_KEY}    || 'YOUR_API_KEY';
my $api_secret  = $ENV{LASTFM_SECRET}     || 'YOUR_SECRET';
my $session_key = $ENV{LASTFM_SESSION_KEY} || 'YOUR_SESSION_KEY';
my $endpoint    = 'https://ws.audioscrobbler.com/2.0/';

# ===============================
# LOAD SCROBBLES
# ===============================
# Option 1: define them inline
my @scrobbles = (
    {
        artist    => 'Radiohead',
        track     => 'Everything In Its Right Place',
        album     => 'Kid A',
        timestamp => time - 300,
    },
    {
        artist    => 'Daft Punk',
        track     => 'Harder, Better, Faster, Stronger',
        album     => 'Discovery',
        timestamp => time - 200,
    },
    {
        artist    => 'Massive Attack',
        track     => 'Teardrop',
        album     => 'Mezzanine',
        timestamp => time - 100,
    },
);

# Option 2: load from a JSON file (e.g. scrobbles.json)
# [
#   {"artist":"Muse","track":"Hysteria","album":"Absolution","timestamp":1731452600},
#   {"artist":"Pink Floyd","track":"Time","album":"Dark Side of the Moon","timestamp":1731452700}
# ]
# Uncomment below if you prefer to load from file:
# my $jsonfile = 'scrobbles.json';
# if (-e $jsonfile) {
#     open my $fh, '<', $jsonfile or die "Can't open $jsonfile: $!";
#     local $/;
#     @scrobbles = @{ decode_json(<$fh>) };
#     close $fh;
# }

# ===============================
# BUILD REQUEST PARAMETERS
# ===============================
my %params = (
    method  => 'track.scrobble',
    api_key => $api_key,
    sk      => $session_key,
);

for my $i (0 .. $#scrobbles) {
    my $s = $scrobbles[$i];
    $params{"artist[$i]"}    = $s->{artist};
    $params{"track[$i]"}     = $s->{track};
    $params{"album[$i]"}     = $s->{album} // '';
    $params{"timestamp[$i]"} = $s->{timestamp} || time;
}

# ===============================
# GENERATE API SIGNATURE
# ===============================
my $sig_string = join('', map { $_ . $params{$_} } sort keys %params) . $api_secret;
$params{api_sig} = md5_hex($sig_string);
$params{format}  = 'json';

# ===============================
# SEND REQUEST
# ===============================
my $ua = LWP::UserAgent->new(agent => 'Perl-LastFM-Scrobbler/1.0');
my $response = $ua->post($endpoint, \%params);

# ===============================
# OUTPUT RESULT
# ===============================
if ($response->is_success) {
    print "✅ Scrobble batch sent successfully!\n";
    print $response->decoded_content . "\n";
} else {
    print "❌ Scrobble failed: " . $response->status_line . "\n";
    print $response->decoded_content . "\n";
}

# Usage
# Save as batch_scrobble.pl

# Make executable:
# Set your API credentials:

export LASTFM_API_KEY="your_api_key"
export LASTFM_SECRET="your_secret"
export LASTFM_SESSION_KEY="your_session_key"

# Run it:

./batch_scrobble.pl
# Example JSON file (scrobbles.json)
[
  {"artist": "Muse", "track": "Hysteria", "album": "Absolution", "timestamp": 1731452600},
  {"artist": "Pink Floyd", "track": "Time", "album": "Dark Side of the Moon", "timestamp": 1731452700}
]

# Then run:

perl batch_scrobble.pl

# Expected Output

{
  "scrobbles": {
    "@attr": {"accepted": "2", "ignored": "0"},
    "scrobble": [
      {"artist": {"#text": "Radiohead"}, "track": {"#text": "Everything In Its Right Place"}},
      {"artist": {"#text": "Daft Punk"}, "track": {"#text": "Harder, Better, Faster, Stronger"}}
    ]
  }
}

# Here’s an upgraded, production-ready Perl script 🧠💪 that:

✅ Reads scrobbles from a JSON file or inline array
✅ Sends them in batches (up to 50 per API call, per Last.fm rules)
✅ Automatically retries failed requests (network or API errors) with exponential backoff
✅ Prints clean success/error output

# robust_scrobbler.pl

#!/usr/bin/perl
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use JSON;
use Time::HiRes qw(sleep);

# ===============================
# CONFIGURATION
# ===============================
my $api_key     = $ENV{LASTFM_API_KEY}    || 'YOUR_API_KEY';
my $api_secret  = $ENV{LASTFM_SECRET}     || 'YOUR_SECRET';
my $session_key = $ENV{LASTFM_SESSION_KEY} || 'YOUR_SESSION_KEY';
my $endpoint    = 'https://ws.audioscrobbler.com/2.0/';
my $max_batch   = 50;   # Last.fm allows up to 50 scrobbles per call
my $max_retries = 3;    # retry failed batches up to 3 times
my $retry_delay = 2;    # seconds (exponential backoff)

# ===============================
# LOAD SCROBBLES
# ===============================
my @scrobbles;

# Option 1: load from a JSON file (recommended)
my $jsonfile = 'scrobbles.json';
if (-e $jsonfile) {
    print "📄 Loading scrobbles from $jsonfile...\n";
    open my $fh, '<', $jsonfile or die "Can't open $jsonfile: $!";
    local $/;
    @scrobbles = @{ decode_json(<$fh>) };
    close $fh;
} else {
    # Option 2: define inline fallback scrobbles
    print "⚠️  No scrobbles.json found — using sample data.\n";
    @scrobbles = (
        { artist => 'Radiohead', track => 'Everything In Its Right Place', album => 'Kid A', timestamp => time - 300 },
        { artist => 'Daft Punk', track => 'Harder, Better, Faster, Stronger', album => 'Discovery', timestamp => time - 200 },
    );
}

die "❌ No scrobbles to send.\n" unless @scrobbles;

# ===============================
# HELPER: SEND ONE BATCH
# ===============================
sub send_batch {
    my ($batch_ref) = @_;
    my %params = (
        method  => 'track.scrobble',
        api_key => $api_key,
        sk      => $session_key,
    );

    for my $i (0 .. $#$batch_ref) {
        my $s = $batch_ref->[$i];
        $params{"artist[$i]"}    = $s->{artist};
        $params{"track[$i]"}     = $s->{track};
        $params{"album[$i]"}     = $s->{album} // '';
        $params{"timestamp[$i]"} = $s->{timestamp} || time;
    }

    # --- Sign request ---
    my $sig_string = join('', map { $_ . $params{$_} } sort keys %params) . $api_secret;
    $params{api_sig} = md5_hex($sig_string);
    $params{format}  = 'json';

    my $ua = LWP::UserAgent->new(agent => 'Perl-LastFM-Scrobbler/2.0');
    $ua->timeout(15);

    my $response = $ua->post($endpoint, \%params);
    return $response;
}

# ===============================
# PROCESS ALL SCROBBLES
# ===============================
my $total = scalar @scrobbles;
print "🎧 Preparing to scrobble $total tracks...\n";

my $sent = 0;
while (@scrobbles) {
    my @batch = splice(@scrobbles, 0, $max_batch);
    my $batch_num = ++$sent;
    my $attempt = 0;

    while ($attempt <= $max_retries) {
        $attempt++;
        print "➡️  Sending batch $batch_num (attempt $attempt)...\n";
        my $response = send_batch(\@batch);

        if ($response->is_success) {
            my $json = decode_json($response->decoded_content);
            if ($json->{scrobbles}{'@attr'}{accepted} > 0) {
                print "✅ Batch $batch_num success! Accepted: $json->{scrobbles}{'@attr'}{accepted}\n";
                last;
            } else {
                warn "⚠️  Batch $batch_num ignored by Last.fm: " . $response->decoded_content . "\n";
            }
        } else {
            warn "❌ HTTP error: " . $response->status_line . "\n";
        }

        # If we reach here, retry
        if ($attempt <= $max_retries) {
            my $delay = $retry_delay ** $attempt;
            print "🔁 Retrying in $delay seconds...\n";
            sleep($delay);
        } else {
            warn "🚫 Failed after $max_retries attempts. Skipping batch.\n";
        }
    }
}

print "🎉 All done!\n";
🔹 JSON Input Example (scrobbles.json)
[
  {"artist": "Muse", "track": "Hysteria", "album": "Absolution", "timestamp": 1731452600},
  {"artist": "Pink Floyd", "track": "Time", "album": "Dark Side of the Moon", "timestamp": 1731452700},
  {"artist": "Aphex Twin", "track": "Xtal", "album": "Selected Ambient Works 85-92", "timestamp": 1731452800}
]

# How to Run
export LASTFM_API_KEY="your_api_key"
export LASTFM_SECRET="your_secret"
export LASTFM_SESSION_KEY="your_session_key"


# What It Does
# Sends up to 50 tracks per batch
# Retries automatically if:
 - HTTP error
 - Temporary Last.fm failure
 - Network timeout

# Uses exponential backoff for retries (2s → 4s → 8s)