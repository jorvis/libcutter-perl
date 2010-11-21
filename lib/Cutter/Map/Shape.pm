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
use Math::Complex;
#use Math::Geometry;
#use Math::Geometry::Planar;


## class data and methods
{

    my %_attributes = (
                        id => undef,
                        
                        has_internal_shapes => undef,
                        
                        ## this obviously remains undef unless it has internals
                        parent_shape => undef,
                        
                        ## corresponds to the 'stroke-width' style attribute
                        width => undef,
                        
                        internal_shapes => undef,
                        
                        ## for each point in this shape, this stores
                        #   the nearest point of each other shape and that
                        #   distance as [{ s => 'cut_15', p => 15, d => 12.134 }
                        #   [ { 'cut_15' => { p=>15, d=>12.134} }, 'cut_12' => {}, ... ], ...
                        neighbor_distances => undef,
                        
                        ## these get reset anytime a Map traversal method
                        #   is called.
                        traversed => 0,
                        internals_traversed => 0,
                        
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
        
        ## initialize any arrays
        $self->{internal_shapes} = [] if ! defined $self->{internal_shapes};
        $self->{neighbor_distances} = [] if ! defined $self->{neighbor_distances};
                
        return $self;
    }

    ## accessors
    sub id { return $_[0]->{id} }
    sub has_internal_shapes { return $_[0]->{has_internal_shapes} }
    sub internal_shapes { return $_[0]->{internal_shapes} }
    sub width { return $_[0]->{width} }
    sub internals_traversed { return $_[0]->{internals_traversed} }
    sub traversed { return $_[0]->{traversed} }
    
    sub point_count { 
        my $points = $_[0]->points();
        return scalar( @$points );
    }

    ## mutators
    sub set_id { $_[0]->{id} = $_[1] }
    sub set_has_internal_shapes { $_[0]->{has_internal_shapes} = $_[1] }
    sub set_width { $_[0]->{id} = $_[1] }
    sub set_parent_shape { $_[0]->{parent_shape} = $_[1] }
    sub reset_traversal {
        $_[0]->{traversed} = 0;
        $_[0]->{internals_traversed} = 0;
    }
    
    sub add_internal_shape {
        my ($self, $shape) = @_;
        
        push @{ $self->{internal_shapes} }, $shape;
        $shape->set_parent_shape( $self );
    }
    
    ## methods
    
    ## each point is an array of (x, y)
    sub distance_between_points {
        my ($self, $point1, $point2) = @_;
        
        my $d = sqrt( ($$point2[0] - $$point1[0])**2 + ($$point2[1] - $$point1[1])**2 );
        #print "\tDEBUG: distance from [$$point1[0],$$point1[1]] to [$$point2[0],$$point2[1]] is $d\n";
        
        return $d;
    }
    
    ## this can be run multiple times against different shapes, the
    #   distance hash is just added to
    sub calculate_neighbor_distances {
        my ($self, $shape) = @_;
        
        my $s1_points = $self->points;
        
        for ( my $s1i=0; $s1i<scalar(@$s1_points); $s1i++ ) {
            
            my $best_point_position = undef;
            my $best_point_distance = undef;
            
            my $s2_points = $shape->points;
            
            for ( my $s2i=0; $s2i<scalar(@$s2_points); $s2i++ ) {
                my $d = $self->distance_between_points( $$s1_points[$s1i], $$s2_points[$s2i] );
                
                if ( ! defined $best_point_distance || $d < $best_point_distance ) {
                    $best_point_position = $s2i;
                    $best_point_distance = $d;
                }
            }
            
            $self->{neighbor_distances}->[$s1i]->{ $shape->id } = 
                { p => $best_point_position, d => $best_point_distance };
        }
    }
}

1==1;













