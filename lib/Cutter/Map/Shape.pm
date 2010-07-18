package Cutter::Map::Shape;

=head1 NAME

Cutter::Map::Shape - A class for representing a shape on a planar cutter 
map.

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=over 3

=item I<PACKAGE>->new( )

Returns a newly created "Cutter::Map::Shape" object.

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
                        id => undef,
                        
                        has_internal_shapes => undef,
                        
                        ## corresponds to the 'stroke-width' style attribute
                        width => undef,
                        
                        points => undef,
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
        $self->{points} = [] if ! defined $self->{points};
        
        return $self;
    }
    

    
    ## accessors
    sub id { return $_[0]->{id} }
    sub has_internal_shapes { return $_[0]->{has_internal_shapes} }
    sub width { return $_[0]->{width} }
    sub points { return $_[0]->{points} }

    ## mutators
    sub set_id { $_[0]->{id} = $_[1] }
    sub set_has_internal_shapes { $_[0]->{has_internal_shapes} = $_[1] }
    sub set_width { $_[0]->{id} = $_[1] }
    sub set_points { $_[0]->{id} = $_[1] }
        
}

1==1;




















