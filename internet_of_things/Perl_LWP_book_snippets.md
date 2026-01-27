## The query portion of a URL assigns values to parameters:

```name=Hiram%20Veeblefeetzer&age=35&country=Madagascar```  

There are three parameters in that query string: name, with the value "Hiram Veeblefeetzer" (the space has been encoded); age, with the value 35; and country, with the value "Madagascar".

The URI::Escape module provides the uri_escape( ) function to help you build URLs:

```use URI::Escape;
encoded_string = uri_escape(raw_string);
For example, to build the name, age, and country query string:

$n = uri_escape("Hiram Veeblefeetzer");
$a = uri_escape(35);
$c = uri_escape("Madagascar");
$query = "name=$n&age=$a&country=$c";
print $query;
name=Hiram%20Veeblefeetzer&age=35&country=Madagascar
``` 
## An HTTP Transaction
The Hypertext Transfer Protocol (HTTP) is used to fetch most documents on the Web. It is formally specified in RFC 2616, but this section explains everything you need to know to use LWP.

HTTP is a server/client protocol: the server has the file, and the client wants it. In regular web surfing, the client is a web browser such as Mozilla or Internet Explorer. The URL for a document identifies the server, which the browser contacts and requests the document from. The server returns either in error ("file not found") or success (in which case the document is attached).

Example 2-1 contains a sample request from a client.

Example 2-1. An HTTP request 
GET /daily/2001/01/05/1.html HTTP/1.1
Host: www.suck.com
User-Agent: Super Duper Browser 14.6
[blank line]  

A successful response is given in Example 2-2.

Example 2-2. A successful HTTP response 
```
HTTP/1.1 200 OK
Content-type: text/html
Content-length: 24204
[blank line]
[and then 24,204 bytes of HTML code]
```
A response indicating failure is given in Example 2-3.

```
Example 2-3. An unsuccessful HTTP response 
HTTP/1.1 404 Not Found
Content-type: text/html
Content-length: 135  
<html><head><title>Not Found</title></head><body>
Sorry, the object you requested was not found.
</body><html>
```

[and then the server closes the connection]  

#### 2.2.1. Request
An HTTP request has three parts: the request line, the headers, and the body of the request (normally used to pass form parameters).

The request line says what the client wants to do (the method), what it wants to do it to (the path), and what protocol it's speaking. Although the HTTP standard defines several methods, the most common are GET and POST. The path is part of the URL being requested (in Example 2-1 the path is /daily/2001/01/05/1.html). The protocol version is generally HTTP/1.1.

Each header line consists of a key and a value (for example, User-Agent: SuperDuperBrowser/14.6). In versions of HTTP previous to 1.1, header lines were optional. In HTTP 1.1, the Host: header must be present, to name the server to which the browser is talking. This is the "server" part of the URL being requested (e.g., www.suck.com). The headers are terminated with a blank line, which must be present regardless of whether there are any headers.

The optional message body can contain arbitrary data. If a body is sent, the request's Content-Type and Content-Length headers help the server decode the data. GET queries don't have any attached data, so this area is blank (that is, nothing is sent by the browser). For our purposes, only POST queries use this third part of the HTTP request.

The following are the most useful headers sent in an HTTP request.

Host: www.youthere.int
This mandatory header line tells the server the hostname from the URL being requested. It may sound odd to be telling a server its own name, but this header line was added in HTTP 1.1 to deal with cases where a single HTTP server answers requests for several different hostnames.  

User-Agent: Thing/1.23 details...
This optional header line identifies the make and model of this browser (virtual or otherwise). For an interactive browser, it's usually something like Mozilla/4.76 [en] (Win98; U) or Mozilla/4.0 (compatible; MSIE 5.12; Mac_PowerPC). By default, LWP sends a User-Agent header of libwww-perl/5.64 (or whatever your exact LWP version is).  

Referer: http://www.thingamabob.int/stuff.html
This optional header line tells the remote server the URL of the page that contained a link to the page being requested.
"Referrer" would be a more correct English spelling of the word, but "Referer" got frozen into the spec years ago. Maybe the blame lies on a UK (or Irish, Indian, etc) person mistakenly assuming that "referer" would be a correct US spelling, the way that UK "traveller" does become "traveler" in the US. Admittedly, it is a confusing enough issue.  

Accept-Language: en-US, en, es, de
This optional header line tells the remote server the natural languages in which the user would prefer to see content, using language tags. For example, the above list means the user would prefer content in U.S. English, or (in order of decreasing preference) any kind of English, Spanish, or German. (Appendix D, "Language Tags" lists the most common language tags.) Many browsers do not send this header, and those that do usually send the default header appropriate to the version of the browser that the user installed. For example, if the browser is Netscape with a Spanish-language interface, it would probably send Accept-Language: es, unless the user has dutifully gone through the browser's preferences menus to specify other languages.  

"www.youthere.int"?  Yes, there's an ".int" TLD.  It's for international treaty organizations (like the World Health Organization or NATO), which means that it will likely be permanently free of clever (or even non-acronymic) domain names.  So I use it extensively as my suffix for nonsense hostnames throughout this book.

Many responses contain a Content-Length line that specifies the length, in bytes, of the body. However, this line is rarely present on dynamically generated pages, and because you never know which pages are dynamically generated, you can't rely on that header line being there.

(Other, rarer header lines are used for specifying that the content has moved to a given URL, or that the server wants the browser to send HTTP cookies, and so on; however, these things are generally handled for you automatically by LWP.)

The body of the response follows the blank line and can be any arbitrary data. In the case of a typical web request, this is the HTML document to be displayed. If an error occurs, the message body doesn't contain the document that was requested but usually consists of a server-generated error message (generally in HTML, but sometimes not) explaining the error.  

LWP::Simple
GET is the simplest and most common type of HTTP request. Form parameters may be supplied in the URL, but there is never a body to the request. The LWP::Simple module has several functions for quickly fetching a document with a GET request. Some functions return the document, others save or print the document.

2.3.1. Basic Document Fetch
The LWP::Simple module's get( ) function takes a URL and returns the body of the document:

$document = get("http://www.suck.com/daily/2001/01/05/1.html");
If the document can't be fetched, get( ) returns undef. Incidentally, if LWP requests that URL and the server replies that it has moved to some other URL, LWP requests that other URL and returns that.

With LWP::Simple's get( ) function, there's no way to set headers to be sent with the GET request or get more information about the response, such as the status code. These are important things, because some web servers have copies of documents in different languages and use the HTTP language header to determine which document to return. Likewise, the HTTP response code can let us distinguish between permanent failures (e.g., "404 Not Found") and temporary failures ("505 Service [Temporarily] Unavailable").

Even the most common type of nontrivial web robot (a link checker), benefits from access to response codes. A 403 ("Forbidden," usually because of file permissions) could be automatically corrected, whereas a 404 ("Not Found") error implies an out-of-date link that requires fixing. But if you want access to these codes or other parts of the response besides just the main content, your task is no longer a simple one, and so you shouldn't use LWP::Simple for it. The "simple" in LWP::Simple refers not just to the style of its interface, but also to the kind of tasks for which it's meant.

## Fetch and Store
One way to get the status code is to use LWP::Simple's getstore( ) function, which writes the document to a file and returns the status code from the response:

```
$status = getstore("http://www.suck.com/daily/2001/01/05/1.html",
                   "/tmp/web.html");  
```  
There are two problems with this. The first is that the document is now stored in a file instead of in a variable where you can process it (extract information, convert to another format, etc.). This is readily solved by reading the file using Perl's built-in open( ) and <FH> operators; see below for an example.

The other problem is that a status code by itself isn't very useful: how do you know whether it was successful? That is, does the file contain a document? LWP::Simple offers the is_success( ) and is_error( ) functions to answer that question:

```
$successful = is_success(status);
$failed     = is_error(status);  
```  
If the status code status indicates a successful request (is in the 200-299 range), is_success( ) returns true. If status is an error (400-599), is_error( ) returns true. For example, this bit of code saves the BookTV (CSPAN2) listings schedule and emits a message if Gore Vidal is mentioned:

```
use strict;
use warnings;
use LWP::Simple;
my $url  = 'http://www.booktv.org/schedule/';
my $file = 'booktv.html';
my $status = getstore($url, $file);
die "Error $status on $url" unless is_success($status);
open(IN, "<$file") || die "Can't open $file: $!";
while (<IN>) {
  if (m/Gore\s+Vidal/) {
    print "Look!  Gore Vidal!  $url\n";
    last;
  }
}
close(IN);
```  

2.3.3. Fetch and Print
LWP::Simple also exports the getprint( ) function:
```
$status = getprint(url);  
```
The document is printed to the currently selected output filehandle (usually STDOUT). In other respects, it behaves like getstore( ). This can be very handy in one-liners such as:

% perl -MLWP::Simple -e "getprint('http://cpan.org/RECENT')||die" | grep Apache
That retrieves http://cpan.org/RECENT, which lists the past week's uploads in CPAN (it's a plain text file, not HTML), then sends it to STDOUT, where grep passes through the lines that contain "Apache."

2.3.4. Previewing with HEAD
LWP::Simple also exports the head( ) function, which asks the server, "If I were to request this item with GET, what headers would it have?" This is useful when you are checking links. Although, not all servers support HEAD requests properly, if head( ) says the document is retrievable, then it almost definitely is. (However, if head( ) says it's not, that might just be because the server doesn't support HEAD requests.)

The return value of head( ) depends on whether you call it in scalar context or list context. In scalar context, it is simply:
```
$is_success = head(url);  
```
If the server answers the HEAD request with a successful status code, this returns a true value. Otherwise, it returns a false value. You can use this like so:
```
die "I don't think I'll be able to get $url" unless head($url);  
```
Regrettably, however, some old servers, and most CGIs running on newer servers, do not understand HEAD requests. In that case, they should reply with a "405 Method Not Allowed" message, but some actually respond as if you had performed a GET request. With the minimal interface that head( ) provides, you can't really deal with either of those cases, because you can't get the status code on unsuccessful requests, nor can you get the content (which, in theory, there should never be any).

In list context, head( ) returns a list of five values, if the request is successful:
```
(content_type, document_length, modified_time, expires, server) = head(url);  
```  
The content_type value is the MIME type string of the form type/subtype; the most common MIME types are listed in Appendix C, "Common MIME Types". The document_length value is whatever is in the Content-Length header, which, if present, should be the number of bytes in the document that you would have gotten if you'd performed a GET request. The modified_time value is the contents of the Last-Modified header converted to a number like you would get from Perl's time( ) function. For normal files (GIFs, HTML files, etc.), the Last-Modified value is just the modification time of that file, but dynamically generated content will not typically have a Last-Modified header.

The last two values are rarely useful; the expires value is a time (expressed as a number like you would get from Perl's time( ) function) from the seldom used Expires header, indicating when the data should no longer be considered valid. The server value is the contents of the Server header line that the server can send, to tell you what kind of software it's running. A typical value is Apache/1.3.22 (Unix).

An unsuccessful request, in list context, returns an empty list. So when you're copying the return list into a bunch of scalars, they will each get assigned undef. Note also that you don't need to save all the values—you can save just the first few, as in Example 2-4.

Example 2-4. Link checking with HEAD 
```
use strict;
use LWP::Simple;
foreach my $url (
  'http://us.a1.yimg.com/us.yimg.com/i/ww/m5v9.gif',
  'http://hooboy.no-such-host.int/',
  'http://www.yahoo.com',
  'http://www.ora.com/ask_tim/graphics/asktim_header_main.gif',
  'http://www.guardian.co.uk/',
  'http://www.pixunlimited.co.uk/siteheaders/Guardian.gif',
) {
  print "\n$url\n";

  my ($type, $length, $mod) = head($url);
  # so we don't even save the expires or server values!

  unless (defined $type) {
    print "Couldn't get $url\n";
    next;
  }
  print "That $type document is ", $length || "???", " bytes long.\n";
  if ($mod) {
    my $ago = time( ) - $mod;
    print "It was modified $ago seconds ago; that's about ",
      int(.5 + $ago / (24 * 60 * 60)), " days ago, at ",
      scalar(localtime($mod)), "!\n";
  } else {
    print "I don't know when it was last modified.\n";
  }
}
```  
Currently, that program prints the following, when run:

```
http://us.a1.yimg.com/us.yimg.com/i/ww/m5v9.gif
That image/gif document is 5611 bytes long.
It was modified 251207569 seconds ago; that's about 2907 days ago, at Thu Apr 14 18:00:00 1994!

http://hooboy.no-such-host.int/
Couldn't get http://hooboy.no-such-host.int/

http://www.yahoo.com
That text/html document is ??? bytes long.
I don't know when it was last modified.

http://www.ora.com/ask_tim/graphics/asktim_header_main.gif
That image/gif document is 8588 bytes long.
It was modified 62185120 seconds ago; that's about 720 days ago, at Mon Apr 10 12:14:13 2000!

http://www.guardian.co.uk/
That text/html document is ??? bytes long.
I don't know when it was last modified.

http://www.pixunlimited.co.uk/siteheaders/Guardian.gif
That image/gif document is 4659 bytes long.
It was modified 24518302 seconds ago; that's about 284 days ago, at Wed Jun 20 11:14:33 2001!
```  

## Fetching Documents Without LWP::Simple  

LWP::Simple is convenient but not all powerful. In particular, we can't make POST requests or set request headers or query response headers. To do these things, we need to go beyond LWP::Simple.

The general all-purpose way to do HTTP GET queries is by using the do_GET( ) subroutine shown in Example 2-5.

Example 2-5. The do_GET subroutine 

```
use LWP;
my $browser;
sub do_GET {
  # Parameters: the URL,
  #  and then, optionally, any header lines: (key,value, key,value)
  $browser = LWP::UserAgent->new( ) unless $browser;
  my $resp = $browser->get(@_);
  return ($resp->content, $resp->status_line, $resp->is_success, $resp)
    if wantarray;
  return unless $resp->is_success;
  return $resp->content;
}
```  
A full explanation of the internals of do_GET( ) is given in Chapter 3, "The LWP Class Model". Until then, we'll be using it without fully understanding how it works.

You can call the ```do_GET( )``` function in either scalar or list context:

```
doc = do_GET(URL [header, value, ...]);
(doc, status, successful, response) = do_GET(URL [header, value, ...]);
```  

In scalar context, it returns the document or undef if there is an error. In list context, it returns the document (if any), the status line from the HTTP response, a Boolean value indicating whether the status code indicates a successful response, and an object we can interrogate to find out more about the response.

Recall that assigning to undef discards that value. For example, this is how you fetch a document into a string and learn whether it is successful:

```
($doc, undef, $successful, undef) = do_GET('http://www.suck.com/');
```  

The optional header and value arguments to do_GET( ) let you add headers to the request. For example, to attempt to fetch the German language version of the European Union home page:

```
$body = do_GET("http://europa.eu.int/",
  "Accept-language" => "de",
);
```

The ```do_GET( )``` function that we'll use in this chapter provides the same basic convenience as LWP::Simple's get( ) but without the limitations.  

## Parsing URLs
Rather than attempt to pull apart URLs with regular expressions, which is difficult to do in a way that works with all the many types of URLs, you should use the URI class. When you create an object representing a URL, it has attributes for each part of a URL (scheme, username, hostname, port, etc.). Make method calls to get and set these attributes.

Example 4-1 creates a URI object representing a complex URL, then calls methods to discover the various components of the URL.

Example 4-1. Decomposing a URL 
```
use URI;
my $url = URI->new('http://user:pass@example.int:4345/hello.php?user=12');
print "Scheme: ", $url->scheme( ), "\n";
print "Userinfo: ", $url->userinfo( ), "\n";
print "Hostname: ", $url->host( ), "\n";
print "Port: ", $url->port( ), "\n";
print "Path: ", $url->path( ), "\n";
print "Query: ", $url->query( ), "\n";
``` 
Example 4-1 prints:
```
Scheme: http
Userinfo: user:pass
Hostname: example.int
Port: 4345
Path: /hello.php
Query: user=12
```
Besides reading the parts of a URL, methods such as ```host( )``` can also alter the parts of a URL, using the familiar convention that $object->method reads an attribute's value and ```$object->method(newvalue)``` alters an attribute:

```
use URI;
my $uri = URI->new("http://www.perl.com/I/like/pie.html");
$uri->host('testing.perl.com');
print $uri,"\n";
http://testing.perl.com/I/like/pie.html
```
Now let's look at the methods in more depth.

## 4.1.1. Constructors
An object of the URI class represents a URL. (Actually, a URI object can also represent a kind of URL-like string called a URN, but you're unlikely to run into one of those any time soon.) To create a URI object from a string containing a URL, use the new( ) constructor:

```
$url = URI->new(url [, scheme ]);
```
If url is a relative URL (a fragment such as ```staff/alicia.html)``` scheme determines the scheme you plan for this URL to have (http, ftp, etc.). But in most cases, you call URI->new only when you know you won't have a relative URL; for relative URLs or URLs that just might be relative, use the URI->new_abs method, discussed below.

The URI module strips out quotes, angle brackets, and whitespace from the new URL. So these statements all create identical URI objects:
```
$url = URI->new('<http://www.oreilly.com/>');
$url = URI->new('"http://www.oreilly.com/"');
$url = URI->new('          http://www.oreilly.com/');
$url = URI->new('http://www.oreilly.com/   ');
```
The URI class automatically escapes any characters that the URL standard (RFC 2396) says can't appear in a URL. So these two are equivalent:
```
$url = URI->new('http://www.oreilly.com/bad page');
$url = URI->new('http://www.oreilly.com/bad%20page');
```
If you already have a URI object, the clone( ) method will produce another URI object with identical attributes:
```
$copy = $url->clone( );
```
Example 4-2 clones a URI object and changes an attribute.

Example 4-2. Cloning a URI
``` 
use URI;
my $url = URI->new('http://www.oreilly.com/catalog/');
$dup = $url->clone( );
$url->path('/weblogs');
print "Changed path: ", $url->path( ), "\n";
print "Original path: ", $dup->path( ), "\n";
```
When run, Example 4-2 prints:
```
Changed path: /weblogs
Original path: /catalog/
```
4.1.2. Output
Treat a URI object as a string and you'll get the URL:
```
$url = URI->new('http://www.example.int');
$url->path('/search.cgi');
print "The URL is now: $url\n";
```
The URL is now: http://www.example.int/search.cgi  
You might find it useful to normalize the URL before printing it  

## 4.1.3. Comparison
To compare two URLs, use the eq( ) method:
```
if ($url_one->eq(url_two)) { ... }
```
For example:
```
use URI;
my $url_one = URI->new('http://www.example.int');
my $url_two = URI->new('http://www.example.int/search.cgi');
$url_one->path('/search.cgi');
if ($url_one->eq($url_two)) {
  print "The two URLs are equal.\n";
}
```
The two URLs are equal.
Two URLs are equal if they are represented by the same string when normalized. The eq( ) method is faster than the eq string operator:

```if ($url_one eq $url_two) { ... } # inefficient!```  

To see if two values refer not just to the same URL, but to the same URI object, use the == operator:
```
if ($url_one == $url_two) { ... }
```
For example:
```
use URI;
my $url = URI->new('http://www.example.int');
$that_one = $url;
if ($that_one == $url) {
  print "Same object.\n";
}
```
Same object

## 4.1.4. Components of a URL

The URI class provides methods to access each component. Some components are available only on some schemes (for example, mailto: URLs do not support the userinfo, host, or port components).

In addition to the obvious scheme( ), userinfo( ), host( ), port( ), path( ), query( ), and fragment( ) methods, there are some useful but less-intuitive ones.  

```
$url->path_query([newval]);
```
The path and query components as a single string, e.g., /hello.php?user=21.  

```
$url->path_segments([segment, ...]);
```

In scalar context, it is the same as path( ), but in list context, it returns a list of path segments (directories and maybe a filename). For example:  
```
$url = URI->new('http://www.example.int/eye/sea/ewe.cgi');
@bits = $url->path_segments( );
for ($i=0; $i < @bits; $i++) {
  print "$i {$bits[$i]}\n";
}
print "\n\n";
0 {}
1 {eye}
2 {sea}
3 {ewe.cgi}
$url->host_port([newval])
```
The hostname and port as one value, e.g., www.example.int:8080.  
```$url->default_port( );```  
The default port for this scheme (e.g., 80 for http and 21 for ftp).
For a URL that simply lacks one of those parts, the method for that part generally returns undef:  
```
use URI;
my $uri = URI->new("http://stuff.int/things.html");
my $query = $uri->query;
print defined($query) ? "Query: <$query>\n" : "No query\n";
No query
```
However, some kinds of URLs can't have certain components. For example, a mailto: URL doesn't have a host component, so code that calls host( ) on a mailto: URL will die. For example:  
```
use URI;
my $uri = URI->new('mailto:hey-you@mail.int');
print $uri->host;
```
Can't locate object method "host" via package "URI::mailto"
This has real-world implications. Consider extracting all the URLs in a document and going through them like this:  
```
foreach my $url (@urls) {
  $url = URI->new($url);
  my $hostname = $url->host;
  next unless $Hosts_to_ignore{$hostname};
  ...otherwise ...
}
```
This will die on a mailto: URL, which doesn't have a host( ) method. You can avoid this by using can( ) to see if you can call a given method:  
```
foreach my $url (@urls) {
  $url = URI->new($url);
  next unless $url->can('host');
  my $hostname = $url->host;
  ...
```
or a bit less directly:  
```
foreach my $url (@urls) {
  $url = URI->new($url);
  unless('http' eq $url->scheme) {
    print "Odd, $url is not an http url!  Skipping.\n";
    next;
  }
  my $hostname = $url->host;
  ...and so forth...
```
Because all URIs offer a scheme method, and all http: URIs provide a host( ) method, this is assuredly safe.[1] For the curious, what URI schemes allow for what is explained in the documentation for the URI class, as well as the documentation for some specific subclasses like URI::ldap.

[1] Of the methods illustrated above, scheme, path, and fragment are the only ones that are always provided. It would be surprising to find a fragment on a mailto: URL—and who knows what it would mean—but it's syntactically possible. In practical terms, this means even if you have a mailto: URL, you can call $url->fragment without it being an error.

## 4.1.5. Queries
The URI class has two methods for dealing with query data above and beyond the query( ) and path_query( ) methods we've already discussed.

In the very early days of the web, queries were simply text strings. Spaces were encoded as plus (+) characters:

```http://www.example.int/search?i+like+pie```
The query_keywords( ) method works with these types of queries, accepting and returning a list of keywords:  
```
@words = $url->query_keywords([keywords, ...]);
```
For example:
```
use URI;
my $url = URI->new('http://www.example.int/search?i+like+pie');
@words = $url->query_keywords( );
print $words[-1], "\n";
pie
```  
More modern queries accept a list of named values. A name and its value are separated by an equals sign (=), and such pairs are separated from each other with ampersands (&):

```http://www.example.int/search?food=pie&action=like```  
The query_form( ) method lets you treat each such query as a list of keys and values:
```
@params = $url->query_form([key,value,...);
```  
For example:
```
use URI;
my $url = URI->new('http://www.example.int/search?food=pie&action=like');
@params = $url->query_form( );
for ($i=0; $i < @params; $i++) {
  print "$i {$params[$i]}\n";
}
0 {food}
1 {pie}
2 {action}
3 {like}
```  

## Relative URLs
URL paths are either absolute or relative. An absolute URL starts with a scheme, then has whatever data this scheme requires. For an HTTP URL, this means a hostname and a path:

#### http://phee.phye.phoe.fm/thingamajig/stuff.html  
Any URL that doesn't start with a scheme is relative. To interpret a relative URL, you need a base URL that is absolute (just as you don't know the GPS coordinates of "800 miles west of here" unless you know the GPS coordinates of "here").

A relative URL leaves some information implicit, which you look to its base URL for. For example, if your base URL is http://phee.phye.phoe.fm/thingamajig/stuff.html, and you see a relative URL of /also.html, then the implicit information is "with the same scheme (http)" and "on the same host (phee.phye.phoe.fm)," and the explicit information is "with the path /also.html." So this is equivalent to an absolute URL of:

#### http://phee.phye.phoe.fm/also.html  
Some kinds of relative URLs require information from the path of the base URL in a way that closely mirrors relative filespecs in Unix filesystems, where ".." means "up one level", "." means "in this level", and anything else means "in this directory". So a relative URL of just zing.xml interpreted relative to http://phee.phye.phoe.fm/thingamajig/stuff.html yields this absolute URL:

#### http://phee.phye.phoe.fm/thingamajig/zing.xml  
That is, we use all but the last bit of the absolute URL's path, then append the new component.

Similarly, a relative URL of ../hi_there.jpg interpreted against the absolute URL http://phee.phye.phoe.fm/thingamajig/stuff.html gives us this URL:

#### http://phee.phye.phoe.fm/hi_there.jpg  
In figuring this out, start with http://phee.phye.phoe.fm/thingamajig/ and the ".." tells us to go up one level, giving us http://phee.phye.phoe.fm/. Append hi_there.jpg giving us the URL you see above.

There's a third kind of relative URL, which consists entirely of a fragment, such as #endnotes. This is commonly met with in HTML documents, in code like so:

#### <a href="#endnotes">See the endnotes for the full citation</a>  
Interpreting a fragment-only relative URL involves taking the base URL, stripping off any fragment that's already there, and adding the new one. So if the base URL is this:

#### http://phee.phye.phoe.fm/thingamajig/stuff.html  
and the relative URL is #endnotes, then the new absolute URL is this:

#### http://phee.phye.phoe.fm/thingamajig/stuff.html#endnotes  
We've looked at relative URLs from the perspective of starting with a relative URL and an absolute base, and getting the equivalent absolute URL. But you can also look at it the other way: starting with an absolute URL and asking "what is the relative URL that gets me there, relative to an absolute base URL?". This is best explained by putting the URLs one on top of the other:

#### Base: http://phee.phye.phoe.fm/thingamajig/stuff.xml  
#### Goal: http://phee.phye.phoe.fm/thingamajig/zing.html  
To get from the base to the goal, the shortest relative URL is simply zing.xml. However, if the goal is a directory higher:

#### Base: http://phee.phye.phoe.fm/thingamajig/stuff.xml  
#### Goal: http://phee.phye.phoe.fm/hi_there.jpg  
then a relative path is ../hi_there.jpg. And in this case, simply starting from the document root and having a relative path of /hi_there.jpg would also get you there.

The logic behind parsing relative URLs and converting between them and absolute URLs is not simple and is very easy to get wrong. The fact that the URI class provides functions for doing it all for us is one of its greatest benefits. You are likely to have two kinds of dealings with relative URLs: wanting to turn an absolute URL into a relative URL and wanting to turn a relative URL into an absolute URL.

## 4.3. Converting Absolute URLs to Relative
A relative URL path assumes you're in a directory and the path elements are relative to that directory. For example, if you're in /staff/, these are the same:  

roster/search.cgi
/staff/roster/search.cgi

If you're in /students/, this is the path to /staff/roster/search.cgi:  

../staff/roster/search.cgi  

The URI class includes a method rel( ), which creates a relative URL out of an absolute goal URI object. The newly created relative URL is how you could get to that original URL, starting from the absolute base URL.

```$relative = $absolute_goal->rel(absolute_base);```  

The absolute_base is the URL path in which you're assumed to be; it can be a string, or a real URI object. But $absolute_goal must be a URI object. The rel( ) method returns a URI object.

For example:  
```
use URI;
my $base = URI->new('http://phee.phye.phoe.fm/thingamajig/zing.xml');
my $goal = URI->new('http://phee.phye.phoe.fm/hi_there.jpg');
print $goal->rel($base), "\n";
../hi_there.jpg
```
If you start with normal strings, simplify this to URI->new($abs_goal)->rel($base), as shown here:  
```
use URI;
my $base = 'http://phee.phye.phoe.fm/thingamajig/zing.xml';
my $goal = 'http://phee.phye.phoe.fm/hi_there.jpg';
print URI->new($goal)->rel($base), "\n";
../hi_there.jpg
```
Incidentally, the trailing slash in a base URL can be very important. Consider:  
```
use URI;
my $base = 'http://phee.phye.phoe.fm/englishmen/blood';
my $goal = 'http://phee.phye.phoe.fm/englishmen/tony.jpg';
print URI->new($goal)->rel($base), "\n";
tony.jpg
```
But add a slash to the base URL and see the change:  
```
use URI;
my $base = 'http://phee.phye.phoe.fm/englishmen/blood/';
my $goal = 'http://phee.phye.phoe.fm/englishmen/tony.jpg';
print URI->new($goal)->rel($base), "\n";
../tony.jpg  
```
## 4.4. Converting Relative URLs to Absolute
By far the most common task involving URLs is converting relative URLs to absolute ones. The new_abs( ) method does all the hard work:  

```$abs_url = URI->new_abs(relative, base);```  
If rel_url is actually an absolute URL, base_url is ignored. This lets you pass all URLs from a document through new_abs( ), rather than trying to work out which are relative and which are absolute. So if you process the HTML at http://www.oreilly.com/catalog/ and you find a link to pperl3/toc.html, you can get the full URL like this:
```
$abs_url = URI->new_abs('pperl3/toc.html', 'http://www.oreilly.com/catalog/');
```  
Another example:  
```
use URI;
my $base_url = "http://w3.thing.int/stuff/diary.html";
my $rel_url  = "../minesweeper_hints/";
my $abs_url  = URI->new_abs($rel_url, $base_url);
print $abs_url, "\n";
http://w3.thing.int/minesweeper_hints/
```
You can even pass the output of new_abs to the canonical method that we discussed earlier, to get the normalized absolute representation of a URL. So if you're parsing possibly relative, oddly escaped URLs in a document (each in $href, such as you'd get from an <a href="..."> tag), the expression to remember is this:  
```
$new_abs = URI->new_abs($href, $abs_base)->canonical;  
```
## 5.2. LWP and GET Requests
The way you submit form data with LWP depends on whether the form's action is GET or POST. If it's a GET form, you construct a URL with encoded form data (possibly using the $url->query_form( ) method) and call $browser->get( ). If it's a POST form, you call $browser->post( ) and pass a reference to an array of form parameters. We cover POST later in this chapter.  

## 5.2.1. GETting Fixed URLs
If you know everything about the GET form ahead of time, and you know everything about what you'd be typing (as if you're always searching on the name "Dulce"), you know the URL! Because the same data from the same GET form always makes for the same URL, you can just hardcode that:  
```
$resp = $browser->get(
  'http://www.census.gov/cgi-bin/gazetteer?city=Dulce&state=&zip='
);
```
And if there is a great big URL in which only one thing ever changes, you could just drop in the value, after URL-encoding it:  
```
use URI::Escape ('uri_escape');
$resp = $browser->get(
  'http://www.census.gov/cgi-bin/gazetteer?city=' . 
  uri_escape($city) .
  '&state=&zip='
);
```
Note that you should not simply interpolate a raw unencoded value, like this:  
```
$resp = $browser->get(
  'http://www.census.gov/cgi-bin/gazetteer?city=' . 
  $city .     # wrong!
  '&state=&zip='
);
```
The problem with doing it that way is that you have no real assurance that $city's value doesn't need URL encoding. You may "know" that no unencoded town name ever needs escaping, but it's better to escape it anyway.

If you're piecing together the parts of URLs and you find yourself calling uri_escape more than once per URL, then you should use the next method, query_form, which is simpler for URLs with lots of variable data.

Since this book went to press, we have a new wrinkle on URL-encoding. The old system I've described here (encoding character 0-255 using two hex digits, %xx) still works, but it provided no answer to the question "what if I want to use a character above 255, like €, or Θ?". The solution is now: If the form's page is in UTF8, then when we go to encode the form data, encoding for characters 0-127 works the same; but above that, you don't encode the character number as %xx, but instead you UTF8-encode the character, which will produce two or more bytes, and then you %xx-encode those bytes.

So: "Appendix F: ASCII Table" tells us that € UTF8-encodes to the three bytes 0xE2,0x82,0xAC. So, assuming the originating page is UTF8 (as opposed to being in the default Latin-1, for example), we encode a € as "%E2%82%AC". Similarly, a Θ UTF8-encodes to the two bytes 0xCE,0x98, so it URL-encodes as "%CE%98". And note that, under this system, é encodes not as "%E9", but instead as "%C3%A9".

That's the backstory. Here's how to handle it in Perl-- You can UTF8 URL-encode things with:
use URI::Escape qw( uri_escape_utf8 );  
```$esc = uri_escape_utf8( some string value )```  
If need to decode data that was encoded this way (or that even might have been), you can use this following subroutine:  
```
sub smartdecode {
  use URI::Escape qw( uri_unescape );
  use utf8;
  my $x = my $y = uri_unescape($_[0]);
  return $x if utf8::decode($x);
  return $y;
}
```
and then use ```$decoded = smartdecode( some string value )```  

## 5.2.2. GETting a query_form( ) URL  
The tidiest way to submit GET form data is to make a new URI object, then add in the form pairs using the query_form method, before performing a $browser->get($url) request:  
```
$url->query_form(name => value, name => value, ...);
```
For example:  
```
use URI;
my $url = URI->new( 'http://www.census.gov/cgi-bin/gazetteer' );
my($city,$state,$zip) = ("Some City","Some State","Some Zip");
$url->query_form(
  # All form pairs:
  'city'  => $city,
  'state' => $state,
  'zip'   => $zip,
);

print $url, "\n"; # so we can see it
```
Prints:

http://www.census.gov/cgi-bin/gazetteer?city=Some+City&state=Some+State&zip=Some+Zip  
From this, it's easy to write a small program (shown in Example 5-1) to perform a request on this URL and use some simple regexps to extract the data from the HTML.

Example 5-1. gazetteer.pl  
```
#!/usr/bin/perl -w
# gazetteer.pl - query the US Cenus Gazetteer database

use strict;
use URI;
use LWP::UserAgent;

die "Usage: $0 \"That Town\"\n" unless @ARGV == 1;
my $name = $ARGV[0];
my $url = URI->new('http://www.census.gov/cgi-bin/gazetteer');
$url->query_form( 'city' => $name, 'state' => '', 'zip' => '');
print $url, "\n";

my $response = LWP::UserAgent->new->get( $url );
die "Error: ", $response->status_line unless $response->is_success;
extract_and_sort($response->content);

sub extract_and_sort {  # A simple data extractor routine
  die "No <ul>...</ul> in content" unless $_[0] =~ m{<ul>(.*?)</ul>}s;
  my @pop_and_town;
  foreach my $entry (split /<li>/, $1) {
    next unless $entry =~ m{^<strong>(.*?)</strong>(.*?)<br>}s;
    my $town = "$1 $2";
    next unless $entry =~ m{^Population \(.*?\): (\d+)<br>}m;
    push @pop_and_town, sprintf "%10s %s\n", $1, $town;
  }
  print reverse sort @pop_and_town;
}
```
Then run it from a prompt:  
```
% perl gazetteer.pl Dulce
```
```
http://www.census.gov/cgi-bin/gazetteer?city=Dulce&state=&zip=
      2438 Dulce, NM  (cdp)
       794 Agua Dulce, TX  (city)
       136 Guayabo Dulce Barrio, PR  (county subdivision)
```
 
```% perl gazetteer.pl IEG```  
```
http://www.census.gov/cgi-bin/gazetteer?city=IEG&state=&zip=
   2498016 San Diego County, CA  (county)
   1886748 San Diego Division, CA  (county subdivision)
   1110549 San Diego, CA  (city)
     67229 Boca Ciega Division, FL  (county subdivision)
      6977 Rancho San Diego, CA  (cdp)
      6874 San Diego Country Estates, CA  (cdp)
      5018 San Diego Division, TX  (county subdivision)
      4983 San Diego, TX  (city)
      1110 Diego Herna]Ndez Barrio, PR  (county subdivision)
       912 Riegelsville, PA  (county subdivision)
       912 Riegelsville, PA  (borough)
       298 New Riegel, OH  (village)
```  

## Cookies
HTTP was originally designed as a stateless protocol, meaning that each request is totally independent of other requests. But web site designers felt the need for something to help them identify the user of a particular session. The mechanism that does this is called a cookie. This section gives some background on cookies so you know what LWP is doing for you.

An HTTP cookie is a string that an HTTP server can send to a client, which the client is supposed to put in the headers of any future requests that it makes to that server. Suppose a client makes a request to a given server, and the response headers consist of this:  
```
Date: Thu, 28 Feb 2002 04:29:13 GMT
Server: Apache/1.3.23 (Win32)
Content-Type: text/html
Set-Cookie: foo=bar; expires=Thu, 20 May 2010 01:23:45 GMT; path=/
```
This means that the server wants all further requests from this client to anywhere on this site (i.e., under /) to be accompanied by this header line:

```Cookie: foo=bar```
That header should be present in all this browser's requests to this site, until May 20, 2010 (at 1:23:45 in the morning), after which time the client should never send that cookie again.

A Set-Cookie line can fail to specify an expiration time, in which case this cookie ends at the end of this "session," where "session" is generally seen as ending when the user closes all browser windows. Moreover, the path can be something more specific than /. It can be, for example, /dahut/, in which case a cookie will be sent only for URLs that begin http://thishost/dahut/. Finally, a cookie can specify that this site is not just on this one host, but also on all other hosts in this subdomain, so that if this host is search.mybazouki.com, cookies should be sent to any hostname under mybazouki.com, including images.mybazouki.com, ads.mybazouki.com, extra.stuff.mybazouki.com, and so on.

All those details are handled by LWP, and you need only make a few decisions for a given LWP::UserAgent object:

Should it implement cookies at all? If not, it will just ignore any Set-Cookie: headers from the server and will never send any Cookie: headers.

Should it load cookies when it starts up? If not, it will start out with no cookies.

Should it save cookies to some file when the browser object is destroyed? If not, whatever cookies it has accumulated will be lost.

What format should the cookies file be in? Currently the choices are either a format particular to LWP, or Netscape cookies files.

## 11.1.1. Enabling Cookies
By default, an LWP::UserAgent object doesn't implement cookies. To make an LWP::UserAgent object that implements cookies is as simple as this:  
```
my $browser = LWP::UserAgent->new( );
$browser->cookie_jar( {} );
```
However, that browser object's cookie jar (as we call its HTTP cookie database) will start out empty, and its contents won't be saved anywhere when the object is destroyed. Incidentally, the above code is a convenient shortcut for what one previously had to do:

## Load LWP class for "cookie jar" objects  
```
use HTTP::Cookies;
my $browser = LWP::UserAgent->new( );
my $cookie_jar = HTTP::Cookies->new( );
$browser->cookie_jar( $cookie_jar );
```
There's not much point to using the long form when you could use the short form instead, but the longer form becomes preferable when you're adding options to the cookie jar.

## 11.1.2. Loading Cookies from a File
To start the cookie jar by loading from a particular file, use the file option to the HTTP::Cookies new method:  
```
use HTTP::Cookies;
my $cookie_jar = HTTP::Cookies->new(
   file     => "/some/where/cookies.lwp",
);
my $browser = LWP::UserAgent->new;
$browser->cookie_jar( $cookie_jar );
```
In that case, the file is read when the cookie jar is created, but it's never updated with any new cookies that the $browser object will have accumulated.

To read the cookies from a Netscape cookies file instead of from an LWP-format cookie file, use a different class, HTTP::Cookies::Netscape, which is just like HTTP::Cookies, except for the format that it reads and writes:  
```
use HTTP::Cookies::Netscape;
my $cookie_jar = HTTP::Cookies::Netscape->new(
   file => "c:/program files/netscape/users/shazbot/cookies.txt",
);
my $browser = LWP::UserAgent->new;
$browser->cookie_jar( $cookie_jar );
```
## 11.1.3. Saving Cookies to a File
To make LWP write out its potentially changed cookie jar to a file when the object is no longer in use, add an autosave => 1 parameter:  
```
use HTTP::Cookies;
my $cookie_jar = HTTP::Cookies->new(
   file     => "/some/where/cookies.lwp",
   autosave => 1,
);
my $browser = LWP::UserAgent->new;
$browser->cookie_jar( $cookie_jar );
```
At time of this writing, using autosave => 1 with HTTP::Cookies::Netscape has not been sufficiently tested and is not recommended.

## 11.1.4. Cookies and the New York Times Site
Suppose that you have felt personally emboldened and empowered by all the previous chapters' examples of pulling data off of news sites, especially the examples of simplifying HTML in Chapter 10, "Modifying HTML with Trees". You decide that a great test of your skill would be to write LWP code that downloads the stories off various newspapers' web sites and saves them all in a format (either plain text, highly simplified HTML, or even WML, if you have an html2wml tool around) that your ancient but trusty 2001-era PDA can read. Thus, you can spend your commute time on the train (or bus, tube, el, metro, jitney, T, etc.) merrily flipping through the day's news stories from papers all over the world.

Suppose also that you have the basic HTML-simplifying code in place (so we shall not discuss it further), and the LWP code that downloads stories from all the newspapers is working fine—except for the New York Times site. And you can't imagine why it's not working! You have a simple HTML::TokeParser program that gets the main page, finds all the URLs to stories in it, and downloads them one at a time. You verify that those routines are working fine. But when you look at the files that it claims to be successfully fetching and saving ($response->is_success returns true and everything!), all you see for each one is a page that says "Welcome to the New York Times on the Web! Already a member? Log in!" When you look at the exact same URL in Netscape, you don't see that page at all, but instead you see the news story that you want your LWP program to be accessing.

Then it hits you: years ago, the first time you accessed the New York Times site, it wanted you to register with an email address and a password. But you haven't seen that screen again, because of... HTTP cookies! You riffle through your Netscape HTTP cookies file, and lo, there you find:
```
.ny times.com TRUE / FALSE 1343279235 RMID 809ac0ad1cff9a6b
```
Whatever this means to the New York Times site, it's apparently what differentiates your copy of Netscape when it's accessing a story URL, from your LWP program when it's accessing that URL.

Now, you could simply hardwire that cookie into the headers of the $browser->get( ) request's headers, but that involves recalling exactly how lines in Netscape cookie databases translate into headers in HTTP request. The optimally lazy solution is to simply enable cookie support in this LWP::UserAgent object and have it read your Netscape cookie database. So just after where you started off the program with this:  
```
use LWP;
my $browser = LWP::UserAgent->new( );
```
Add `this:  
```
use HTTP::Cookies::Netscape;
my $cookie_jar = HTTP::Cookies::Netscape->new(
 'file' => 'c:/program files/netscape/users/me/cookies.txt'
);
$browser->cookie_jar($cookie_jar);
```
With those five lines of code added, your LWP program's requests to the New York Times's server will carry the cookie that says that you're a registered user. So instead of giving your LWP program the "Log in!" page ad infinitum, the New York Times's server now merrily serves your program the news stories. Success!




