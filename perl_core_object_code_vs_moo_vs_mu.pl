https://perladvent.org/2024/2024-12-24.html

Perl 5

################################################################################################
# Learning Perl 5's object model meant the kind of Perl I would write would be more like this: #
################################################################################################

use strict;
use warnings;
package Triangle;

sub new {
    my $class = shift;
    my %args = @_;
    my $self = { width => $args{width}, height => $args{height} };
    return bless $self, $class;
}

sub width  { return $self->{width} }
sub height { return $self->{height} }

sub area {
    my $self = shift;
    return $self->width * $self->height / 2;
}

package main;
my $shape = Triangle->new(width => 3, height => 4);
print $shape->area(), "\n";

#####################################################################################
# In 2006 along came Moose which enabled a much more powerful way to write objects: #
#####################################################################################

package Triangle;
use Moose;

has width  => (is => 'ro');
has height => (is => 'ro');

sub area {
    my $self = shift;
    return $self->width * $self->height / 2;
}

package main;
use strict;
use warnings;

my $shape = Triangle->new(width => 3, height => 4);
print $shape->area(), "\n";

###################################################################################################
# In 2017, we had the first release of Mu which allows us to write something quite a bit shorter: #
###################################################################################################

package Triangle;
use Mu;

ro 'width';
ro 'height';

sub area {
    my $self = shift;
    return $self->width * $self->height / 2;
}

package main;
use strict;
use warnings;

my $shape = Triangle->new(width => 3, height => 4);
print $shape->area(), "\n";

#########################################################################################################################################################
# This is not only shorter, but it also has more error checking - if you don't pass both width and height to new, you'll get an error                   #
# Perl 5.38 brought into core a bunch of syntax (admirably still experimental) that we started as a community playing with in 2008 with MooseX::Declare #
# but implemented much better and safer. The code above can now be simplified even further:                                                             #
#########################################################################################################################################################

use v5.38;
use feature 'class';

class Triangle {
    field $width  :param;
    field $height :param;
    method area { return $width * $height / 2 }
}

my $shape = Triangle->new(width => 3, height => 4);
say $shape->area();
