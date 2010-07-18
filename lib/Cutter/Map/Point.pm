package Cutter::Map::Point;

=head1 NAME

Cutter::Map::Shape - A class for representing a point of a shape on a 
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
                        ## values may be constructed | svg
                        source => undef,
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
        
        ## initialize any arrays
        #$self->{shapes} = [] if ! defined $self->{shapes};
        
        return $self;
    }

    
    ## accessors
    sub source { return $_[0]->{source} }

    ## mutators
    sub set_source { $_[0]->{source} = $_[1] }
        
}

1==1;




















