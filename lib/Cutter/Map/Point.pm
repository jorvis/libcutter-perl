package Cutter::Map::Point;

=head1 NAME

Cutter::Map::Point - A class for representing a point of a shape on a 
planar cutter map.

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=over 3

=item I<PACKAGE>->new( )

Returns a newly created "Cutter::Map::Point" object.

=back

=head1 AUTHOR

    Joshua Orvis
    jorvis@users.sf.net

=cut

use strict;
use Carp;

## class data and methods
{

    my %_attributes = (
                        x => undef,
                        y => undef,
                      );

    ## class variables
    ## currently none

    sub new {
        my ($class, %args) = @_;

        ## create the object
        my $self = bless { %_attributes }, $class;
        
        ## set any attributes passed, checking to make sure they
        ##  were all valid
        for (keys %args) {
            if (exists $_attributes{$_}) {
                $self->{$_} = $args{$_};
            } else {
                croak("$_ is not a recognized attribute");
            }
        }
        
        return $self;
    }

    
    ## accessors
    sub x { return $_[0]->{x} }
    sub y { return $_[0]->{y} }

    ## mutators
    sub set_x { $_[0]->{x} = $_[1] }
    sub set_y { $_[0]->{y} = $_[1] }
        
}

1==1;




















