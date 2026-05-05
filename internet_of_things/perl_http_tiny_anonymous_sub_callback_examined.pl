#################################################################
## perl http tiny examined callback is an anonymous subroutine ##
#################################################################

data_callback => sub { do_something_here() }

# The sub { ... } part is the anonymous subroutine. The confusing part is the =>, which is not assignment

What => actually means... the fat comma => is basically a comma with a bonus feature:

data_callback => sub { ... }

# is interpreted as:

data_callback, sub { ... }

# So it’s not assigning anything

#########################################
## It’s creating a hash key–value pair ##
#########################################

# In the context of HTTP::Tiny
# When you see this:

my $response = $http->get($url, {
    data_callback => sub {
        my ($chunk, $response) = @_;
        print $chunk;
    }
  }
);

## What’s happening:
# { ... } creates an anonymous hash
# data_callback => sub { ... } is a key-value pair
# key: "data_callback"
# value: the anonymous sub

#############################
# So internally, it’s like: #
#############################

{
    "data_callback" => REFERENCE
}

###################################################################
# Why this pattern is used                                        #
# Modules like HTTP::Tiny expect options as a hash reference:     #    
# data_callback# tells it: “call this function when data arrives” #
# The value is your anonymous sub (callback)                      #
###################################################################

####################
# Think of it like #
####################

options = {
    "when data arrives" : function() { ... }
}

✔ sub { ... } → anonymous subroutine
✔ => → key/value separator (like a comma, not assignment)
✔ Used inside a hash to pass options (like callbacks)
