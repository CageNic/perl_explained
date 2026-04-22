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

# server and via in the repsonse headers

Those two headers tell you a lot about how your request was handled behind the scenes, not just what came back.
________________________________________
server — who actually generated the response
•	server => 'openresty'
This header identifies the origin server software that produced the response.
What is OpenResty?
OpenResty is a bundle built on top of Nginx that adds:
•	Lua scripting support inside the web server
•	High-performance request handling
•	Commonly used for APIs, gateways, and high-traffic sites
What it implies in your case
•	The request ultimately hit a server running OpenResty
•	That server generated the HTML response you received
•	It may be running custom logic (via Lua) rather than just serving static files
Important nuance
The server header:
•	Can be misleading or intentionally vague
•	Many systems hide or overwrite it for security reasons
•	But here it’s exposed, which is fairly common
________________________________________
via — what intermediaries handled your request
•	via => '1.1 google'
This header shows that your request/response passed through one or more intermediate proxies.
Breaking it down
•	1.1 → HTTP version used between proxy layers
•	google → the proxy/caching layer (Google infrastructure)
What “google” means here
This typically indicates the traffic went through:
•	Google’s edge network (CDN or proxy)
•	Possibly services like:
•	Google Front End (GFE)
•	Cloud load balancing
•	Caching layers
________________________________________
How server and via relate (the real path)
Think of the request path like this:
Your Perl client
      ↓
Google proxy/CDN  ← (via: 1.1 google)
      ↓
Origin server (OpenResty)  ← (server: openresty)
      ↓
Response back through Google
      ↓
You
So:
•	server = the origin that created the response
•	via = the middleman(s) that forwarded it
________________________________________
Why this setup exists
Performance
•	Google’s edge servers cache or accelerate responses
•	Reduces latency globally
Reliability
•	Proxies can handle load balancing and failover
Security
•	Shields the origin server from direct exposure
________________________________________
Subtle implications in your headers
Combining:
•	via: 1.1 google
•	alt-svc: h3=":443"
suggests:
•	You’re interacting with a modern edge network
•	It supports newer protocols like HTTP/3
•	The origin (OpenResty) is likely behind that edge
________________________________________
One practical takeaway
If you’re debugging:
•	Problems might not be on the OpenResty server itself
•	They could be caused by caching or behavior in the Google proxy layer
________________________________________
If you want, I can show how to detect multiple Via hops or how CDNs alter headers like X-Forwarded-For—that’s where things get really interesting.


who dictates the request goes through google


Short answer: you didn’t explicitly choose Google — the site owner did (or their infrastructure did).
That via: 1.1 google header appears because the request was routed through Google’s network acting as a proxy/CDN, and that routing is controlled on the server side, not by your Perl client.
________________________________________
Who actually decides this?
1. The website/service owner
In your case, the API endpoint for Last.fm is configured so that traffic goes through Google’s edge infrastructure.
They might be using:
•	Google Cloud load balancing
•	Google’s CDN
•	Or Google Front End (GFE), which sits in front of many services
So the owner sets up DNS and infrastructure like:
api.last.fm → Google edge → origin server (OpenResty)
________________________________________
2. DNS configuration
When your client resolves the hostname (e.g. ws.audioscrobbler.com), DNS may return:
•	IPs belonging to Google
•	Not the origin server directly
So your client thinks it’s connecting to the site, but is actually hitting Google’s edge first.
________________________________________
3. Reverse proxy / CDN layer
Google acts as a reverse proxy:
•	Receives your request
•	Forwards it to the backend (OpenResty)
•	Returns the response to you
That’s why:
•	server = openresty → origin server
•	via = 1.1 google → proxy layer in between
________________________________________
What your client controls (and doesn’t)
You control:
•	The URL you request
•	Headers you send
•	Whether you use a proxy (explicitly)
You do NOT control:
•	Whether the destination site uses a CDN or proxy
•	Which infrastructure sits in front of the origin
________________________________________
Could this ever be client-controlled?
Yes, but not in your case. The Via header could also come from:
•	A corporate proxy
•	A VPN
•	A custom HTTP proxy you configured in Perl
If that were happening, you’d usually see something like:
via: 1.1 corporate-proxy.local
But “google” strongly indicates server-side infrastructure, not your local setup.
________________________________________
Mental model
Think of it like calling a company:
•	You dial the main number → (DNS)
•	A receptionist answers → (Google proxy)
•	They forward you to the actual department → (OpenResty server)
You didn’t choose the receptionist — the company set that up.
________________________________________
If you want, I can show how to confirm this with dig, traceroute, or by inspecting TLS certificates—those give strong clues about which network you’re actually hitting.


explain CDN. I see this a lot for a hosting site for e.g. wordpress images


A CDN (Content Delivery Network) is essentially a distributed network of servers placed around the world that serve content to users from the location closest to them.
Instead of every request going back to one central server, a CDN puts copies (or cached versions) of your content on many “edge” servers globally.
________________________________________
Simple mental model
Without a CDN:
User (London) → Server (New York) → response
With a CDN:
User (London) → London edge server → response
Same content, much shorter trip.
________________________________________
What a CDN actually does
1. Caching content
The CDN stores copies of files like:
•	Images
•	CSS/JS
•	Fonts
•	Sometimes full HTML pages
So when someone requests an image:
•	First request → CDN fetches from origin server
•	Later requests → served directly from CDN cache
________________________________________
2. Geographic distribution
CDNs run servers (“edge nodes”) worldwide via providers like:
•	Cloudflare
•	Akamai Technologies
•	Amazon Web Services (CloudFront)
•	Google Cloud
These edge nodes sit physically closer to users.
________________________________________
3. Acting as a reverse proxy
Like what you saw with via: google, a CDN:
•	Receives your request first
•	Decides whether to serve from cache or forward to origin
•	Sends the response back
________________________________________
Why WordPress sites use CDNs (your example)
On a typical WordPress site:
•	Images are often large and numerous
•	Visitors may come from all over the world
So instead of:
example.com/wp-content/uploads/image.jpg
You’ll often see something like:
cdn.example.com/image.jpg
That cdn. subdomain points to a CDN, not the original server.
________________________________________
What happens when you load an image
1.	Browser requests image
2.	DNS points to CDN (not origin server)
3.	CDN checks:
•	Cached? → return immediately
•	Not cached? → fetch from origin, store it, then return
4.	Future users get the cached version
________________________________________
Benefits
Speed
•	Lower latency (closer servers)
•	Faster page loads
Scalability
•	Handles traffic spikes (CDN absorbs load)
Reliability
•	If one node fails, others take over
Security
•	Shields origin server
•	Often includes DDoS protection
________________________________________
Common headers that reveal a CDN
You’ll often see:
•	via → shows proxy layer (like your google)
•	x-cache → HIT or MISS (was it cached?)
•	cf-cache-status → specific to Cloudflare
•	age → how long the object has been cached
________________________________________
One subtle but important point
A CDN doesn’t always store everything:
•	Static assets (images, CSS) → almost always cached
•	Dynamic content (API responses, user data) → often passed through
So in your Perl example:
•	The request likely passed through Google’s edge
•	But the HTML wasn’t heavily cached (it’s tiny and dynamic-ish)
________________________________________
Analogy that actually fits
Think of a CDN like a chain of local warehouses:
•	Main factory = origin server
•	Warehouses worldwide = CDN nodes
•	Customers order → get product from nearest warehouse
Faster delivery, less strain on the factory.
________________________________________
If you want, I can walk through how to tell which CDN a site is using just from headers or DNS—that’s a handy debugging skill.


yes


Great—this is a really useful skill once you know what to look for. You can usually identify a CDN from headers, DNS, and TLS details without any special tools.
________________________________________
1. Look at HTTP headers (fastest clue)
Certain headers are basically fingerprints.
Common CDN-specific headers
•	Cloudflare
•	cf-ray
•	cf-cache-status
•	Server often shows cloudflare
→ Cloudflare
•	Akamai
•	x-akamai-*
•	akamai-cache-status
→ Akamai Technologies
•	Amazon CloudFront
•	x-amz-cf-id
•	x-cache: Hit from cloudfront
→ Amazon Web Services
•	Fastly
•	x-served-by
•	x-cache: HIT (often paired with Fastly naming)
→ Fastly
•	Google (what you saw)
•	via: 1.1 google
•	Sometimes x-cache: HIT with Google hints
→ Google Cloud
________________________________________
Your example
via: 1.1 google
That strongly suggests:
•	Google edge infrastructure
•	Acting as a CDN/reverse proxy
________________________________________
2. Check DNS (very reliable)
Run something like:
dig example.com
What to look for
•	CNAME chains pointing to CDN domains:
Examples:
•	example.com → something.cloudflare.net
•	example.com → something.akamai.net
•	example.com → something.cloudfront.net
That’s a dead giveaway.
________________________________________
WordPress-style CDN example
A WordPress site might have:
cdn.example.com → example.wpenginepowered.com → CDN
or:
images.example.com → d123abc.cloudfront.net
________________________________________
3. Use curl -I (quick inspection)
curl -I https://example.com
Look for:
•	via
•	x-cache
•	CDN-specific headers
•	unusual server values
________________________________________
4. Inspect TLS certificate
openssl s_client -connect example.com:443
Sometimes the certificate is issued to:
•	the CDN provider
•	or managed by them
For example:
•	Cloudflare certs often issued via Cloudflare-managed CA
•	Google often uses its own infrastructure
________________________________________
5. Look at IP ownership
dig example.com +short
Then check the IP:
•	If it belongs to Google, Amazon, etc., that’s a strong signal
________________________________________
6. Browser DevTools (easy method)
In Chrome/Firefox:
•	Open DevTools → Network tab
•	Click a request
•	Check Response Headers
You’ll often see CDN hints immediately
________________________________________
Putting it all together (your case)
From your headers:
server: openresty
via: 1.1 google
Interpretation:
•	OpenResty → origin server (actual app)
•	Google → CDN / proxy layer in front
So:
Client → Google edge (CDN) → OpenResty (origin)
________________________________________
Quick cheat sheet
Signal	Meaning
via:	proxy/CDN involved
x-cache: HIT	served from cache
cf-* headers	Cloudflare
*.cloudfront.net	AWS CDN
*.akamai.net	Akamai
Google IP + via: google	Google CDN
________________________________________
One subtle trick
Sometimes CDNs hide themselves:
•	They remove identifying headers
•	They mimic origin headers
In that case, DNS + IP ownership is your best bet.
________________________________________

# headers from https://thewonderfulworldofcinema.wordpress.com/

'headers' => { 'transfer-encoding' => 'chunked',
               'date' => 'Wed, day month year xx:xx:xx GMT',
               'x-nananana' => 'Batcache-Hit',
               'server-timing' => 'a8c-cdn, dc;desc=lhr, cache;desc=HIT;dur=1.0',
               'last-modified' => 'Wed, day month year xx:xx:xx GMT',
               'cache-control' => 'max-age=230, must-revalidate',
               'strict-transport-security' => 'max-age=31536000',
               'host-header' => 'WordPress.com',
               'x-hacker' => 'Want root? Visit join.a8c.com/hacker and mention this header.',
               'server' => 'nginx',
               'vary' => [ 'Accept-Encoding', 'accept, content-type, cookie' ],
               'content-type' => 'text/html; charset=UTF-8',
               'alt-svc' => 'h3=":443"; ma=86400',
               'connection' => 'keep-alive', 'x-ac' => '32.lhr _dfw HIT',
               'link' => [ '<https://public-api.wordpress.com/wp-json/?rest_route=/sites/thewonderfulworldofcinema.wordpress.com>; rel="https://api.w.org/"',
               '<https://wp.me/5ex6T>; rel=shortlink' ] },
               'status' => '200',
               'success' => !!1,
               'reason' => 'OK',
               'url' => 'https://thewonderfulworldofcinema.wordpress.com/'
                };

This is a great example—there’s a lot going on here, and it clearly shows a CDN-heavy WordPress setup. Let’s unpack it and then reconstruct the full path.
________________________________________
Big picture first
This site is hosted on WordPress.com (run by Automattic), and the request is being served through their global CDN layer, not directly from a single origin server.
You can already see multiple hints:
•	x-ac
•	server-timing
•	Batcache-Hit
•	location codes like lhr and dfw
________________________________________
Key CDN / infrastructure headers
x-nananana: Batcache-Hit
This is both fun and informative.
•	Batcache is a caching layer used by WordPress.com
•	Hit means:
→ The response was served from cache, not generated fresh
So your request never hit the application logic—it was served instantly.
________________________________________
server-timing: a8c-cdn, dc;desc=lhr, cache;desc=HIT;dur=1.0
This is one of the most revealing headers.
Breakdown:
•	a8c-cdn → CDN operated by Automattic
•	dc;desc=lhr → data center = London (Heathrow)
•	cache;desc=HIT → served from cache
•	dur=1.0 → ~1 ms processing time
👉 Translation:
You were served from a London edge node, extremely quickly, from cache.
________________________________________
x-ac: 32.lhr _dfw HIT
This is another internal routing/debug header.
•	lhr → London (edge node near you)
•	_dfw → Dallas/Fort Worth (likely origin or another tier)
•	HIT → cache hit
👉 This suggests a multi-layer CDN:
You → London edge (lhr) → (would fall back to Dallas if needed) → origin
But since it’s a HIT, it never needed Dallas.
________________________________________
server: nginx
•	The web server software at the edge
•	Likely running on CDN nodes, not necessarily the origin
Nginx is commonly used in:
•	CDNs
•	reverse proxies
•	high-performance setups
________________________________________
Caching behavior
cache-control: max-age=230, must-revalidate
•	Cache is valid for 230 seconds (~4 minutes)
•	After that, it must be revalidated
________________________________________
last-modified
•	Timestamp of last content update
•	Used for conditional requests
________________________________________
vary
Accept-Encoding
accept, content-type, cookie
This tells caches:
•	Different versions may exist depending on:
•	compression
•	cookies (important for logged-in vs anonymous users)
________________________________________
Transport / connection details
transfer-encoding: chunked
•	Response is streamed in chunks
•	No fixed content-length
________________________________________
connection: keep-alive
•	TCP connection stays open for reuse
________________________________________
alt-svc: h3=":443"
•	HTTP/3 is available (QUIC)
•	Cached for 1 day
________________________________________
Security
strict-transport-security
•	Forces HTTPS for 1 year
•	Protects against downgrade attacks
________________________________________
WordPress-specific hints
host-header: WordPress.com
•	Confirms platform
________________________________________
link headers
These expose API endpoints:
•	REST API:
/wp-json/
•	Shortlink:
wp.me
________________________________________
x-hacker
Just a fun easter egg from Automattic:
“Want root? Visit join.a8c.com/hacker…”
________________________________________
Reconstructing the full path
Based on everything:
Your client (London)
        ↓
Automattic CDN edge (London - lhr)
        ↓
(Batcache layer — HIT, so stop here)
        ↓
(No need to تماس Dallas or origin)
If it were a MISS:
You → London edge → Dallas node (_dfw) → origin app → back to cache
________________________________________
What’s especially interesting here
1. You hit a local edge node
•	lhr = London
•	That’s why it’s fast
2. Multi-tier caching
•	Edge cache (London)
•	Possibly regional cache (Dallas)
•	Then origin
3. Application-level caching (Batcache)
•	Not just CDN caching
•	WordPress itself is optimized for scale
________________________________________
Quick fingerprint summary
If you saw just this:
•	x-ac
•	Batcache-Hit
•	a8c-cdn
•	WordPress.com
You can confidently say:
👉 “This is WordPress.com infrastructure with Automattic’s CDN, multi-layer cached, served from a local edge node.”
________________________________________

