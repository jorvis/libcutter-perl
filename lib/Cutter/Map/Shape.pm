package Cutter::Map::Shape;

use base 'Math::Polygon';

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
                      );

    ## class variables
    ## currently none

    sub new {
        my ($class, %args) = @_;

        ## create the object
        #my $self = bless { %_attributes }, $class;
        my $self = $class->SUPER::new( %args );
        
        ## set any extra attributes passed
        for (keys %args) {
            if (exists $_attributes{$_}) {
                $self->{$_} = $args{$_};
            }
        }
        
        return $self;
    }
    

    
    ## accessors
    sub id { return $_[0]->{id} }
    sub has_internal_shapes { return $_[0]->{has_internal_shapes} }
    sub width { return $_[0]->{width} }

    ## mutators
    sub set_id { $_[0]->{id} = $_[1] }
    sub set_has_internal_shapes { $_[0]->{has_internal_shapes} = $_[1] }
    sub set_width { $_[0]->{id} = $_[1] }
    
    sub add_point {
        my ($self, $point) = @_;
        
        push @{ $self->{points} }, $point;
    }
        
}

1==1;




















