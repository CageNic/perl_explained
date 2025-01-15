#############################################
# Configuring LWP::UserAgent to Use a Proxy #
#############################################

#######################################################################################################
# Method 1 - use environment variables - set the HTTP_PROXY or HTTPS_PROXY env vars to your proxy URL #
#######################################################################################################

$ENV{HTTP_PROXY} = '<http://192.168.1.42:8080>';

$ua = LWP::UserAgent->new;
$ua->env_proxy;

# This automatically picks up the proxy from the environment

###################################################################################
# Method 2 - The proxy () method - directly pass the proxy to use through proxy() #
###################################################################################

my $ua = LWP::UserAgent->new;
$ua->proxy('http', '<http://proxy.example.com:8080>');

# set protocols_allowed to enforce using the proxy:

$ua->protocols_allowed(['http']);
