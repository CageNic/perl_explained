#### What Happens to Perl & Unix Tools when using a VPN  

Example Perl code:
```
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
print $ua->get('https://ifconfig.me')->decoded_content;
```
If VPN is active:  
 - The request exits via VPN IP    
 - Same as browser traffic  
 - No proxy settings needed  

#### DNS Matters  
A VPN can leak your real IP if DNS is not routed properly.
 - What to check
 - resolvectl status
 - Ensure DNS servers:

Are provided by VPN
Or are secure (e.g. 10.x.x.x, 100.x.x.x)  
Good VPNs push DNS automatically  

#### Split Tunneling vs Full Tunneling
Full tunnel (default, safest)
 - ALL traffic goes through VPN

#### Split tunnel
 - Some traffic bypasses VPN
 - 
Often used for local LAN access
On Linux, split tunneling is explicitly configured, not automatic  

#### How to Verify Everything Is Covered
- Browser  
 - Visit: https://ipleak.net  
- Terminal
```
curl ifconfig.me
```
- Perl
```
use IO::Socket::INET;
print IO::Socket::INET->new(
    PeerAddr => 'ifconfig.me',
    PeerPort => 80,
    Proto    => 'tcp'
)->peerhost;
``` 
All three should report the same VPN IP.
