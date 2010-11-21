package Cutter::Map;

=head1 NAME

Cutter::Map - A class for representing a planar cutter map.

=head1 SYNOPSIS


=head1 DESCRIPTION

A planar cutter map is a series of points defining shapes on a plane to
be cut out of some material. A map can contain one or more
Cutter::Map::Shape objects.

=head1 METHODS

=over 3

=item I<PACKAGE>->new( )

Returns a newly created "Cutter::Map" object.

=item I<$OBJ>->parse_from_svg( path => I<'/path/to/some.svg'> )

Parses a SVN map file and returns a Cutter::Map object.

=back

=head1 ASSUMPTIONS

- If a polyline has "cut:" in its style attribute, it has no internal pieces.
- No shapes cross boundaries of other shapes
- There are no shapes within shapes within shapes (3-deep)

=head1 AUTHOR

Joshua Orvis
jorvis@users.sf.net

=cut

use strict;
use Carp;
use Cutter::Map::Shape;
use XML::Twig;

## class data and methods
{

    my %_attributes = (
                        ## values may be constructed | svg
                        source => undef,
                        
                        ## if parsed from something, here's the source
                        path => undef,
                        
                        ## populated by any of the parsing methods
                        shapes => undef,
                      );

    ## class variables
    ## currently none

    sub new {
        my ($class, %args) = @_;

        ## create the object
        my $self = bless { %_attributes }, $class;
        
        ## set any attributes passed, checking to make sure they
        ## were all valid
        for (keys %args) {
            if (exists $_attributes{$_}) {
                $self->{$_} = $args{$_};
            } else {
                croak("$_ is not a recognized attribute");
            }
        }
        
        ## initialize any data structures
        $self->{shapes} = [] if ! defined $self->{shapes};
        $self->{point_matrix} = {} if ! defined $self->{point_matrix};
        
        
        return $self;
    }
    
    ## accessors
    sub source { return $_[0]->{source} }
    sub path { return $_[0]->{path} }
    sub shapes { return $_[0]->{shapes} }

    ## mutators
    sub set_path { $_[0]->{path} = $_[1] }
    sub set_shapes { $_[0]->{shapes} = $_[1] }
    sub set_source { $_[0]->{source} = $_[1] }
    
    sub parse_from_svg {
        my ($self, %args) = @_;
        
        ## record whether a path was defined
        if ( $args{path} ) {
            $self->set_path( $args{path} );
        }
        
        ## we can't continue if path wasn't defined by some method
        if ( ! $self->path ) {
            croak( "Can't call parse_from_svn method without having defined a path" );
        }
        
        $self->_parse_svg_file( path => $self->path );
        $self->_calculate_internals();
        $self->_calculate_point_distance_matrix();
        
        return $self;
    }    
    
    sub traverse {
        my ($self, %args) = @_;
        
        for my $shape ( @{$self->shapes} ) { 
            $shape->reset_traversal;
        }
        
        my $shape_count_left = scalar(@{$self->shapes});
        
        my $steps = [];
        
        ## start at point 0,0
        my $pos = [0,0];
        
        ## find closest shape
        my ( $this_shape, $this_shape_point_index, $this_shape_point_distance ) =
            $self->_find_nearest_valid_shape( point => $pos );
        
        print "DEBUG: Nearest shape to [0,0] is " . $this_shape->id . " at index " .
              "$this_shape_point_index and distance $this_shape_point_distance\n";
        
        my $this_shape_points = $this_shape->points;
        
        push @$steps, [ 'off', $pos, $$this_shape_points[$this_shape_point_index] ];
        
        ## traverse shape, find closest shape, repeat
        NOW WALK!
        
        return $steps;
    }
    
    ## finds the nearest shape to a specified point that is not already
    #   traversed, and has no children yet to traverse.  If you've done
    #   _calculate_point_distance_matrix you shouldn't have to call this
    #   since proximal points to each shape are already stored.
    sub _find_nearest_valid_shape {
        my ( $self, %args ) = @_;
        
        if ( ! defined $args{point} ) {
            croak( "Can't call the _find_nearest_valid_shape method without passing a point" );
        }
        
        my $nearest_shape = undef;
        my $nearest_shape_point_index = undef;
        my $nearest_point_distance = undef;
        
        for my $shape ( @{$self->shapes} ) {
            print "DEBUG: checking point distances on shape " . $shape->id . "\n";
        
            ## skip it if it's already been traversed
            next if $shape->traversed;
        
            ## if this has non-traversed internal shapes, skip it
            if ( $shape->has_internal_shapes &&
                 $shape->internals_traversed < scalar( @{$shape->internal_shapes} ) ) {
            
                next;
            }
            
            ## here we go
            my $points = $shape->points;
            
            for ( my $i=0; $i<scalar(@$points); $i++ ) {
                my $d = $shape->distance_between_points( $args{point}, $$points[$i] );
                
                print "\tindex $i distance = $d\n";
                
                if ( ! defined $nearest_point_distance || $d < $nearest_point_distance ) {
                    $nearest_point_distance = $d;
                    $nearest_shape = $shape;
                    $nearest_shape_point_index = $i;
                }
            }
        }
        
        if ( ! defined $nearest_shape ) {
            croak("attempt to find nearest shape failed, no valid shapes remaining");
        }
        
        return ( $nearest_shape, $nearest_shape_point_index, $nearest_point_distance );
    }
    
    ## calculates which shapes are internal to which others in the map.
    sub _calculate_internals {
        my ($self, %args) = @_;
        
        for my $qry_shape ( @{ $self->shapes } ) {
            ## if this shape isn't closed it can't truly contain other shapes
            next unless $qry_shape->isClosed();
        
            for my $ref_shape ( @{ $self->shapes } ) {
                ## don't compare to self
                next if ( $qry_shape->id() eq $ref_shape->id() );
                
                ## By owen's definition, his shapes can't overlap, so
                #  we pick an arbitrary point to test containment.
                my $first_point = ( $ref_shape->points )[0];
                
                if ( $qry_shape->contains( $first_point ) ) {
                    $qry_shape->add_internal_shape( $ref_shape );
                }
            }
        }
    }
    
    ## this is expensive, and perhaps not practical for large maps
    #   it could definitely be improved.
    #   get it working, then make it elegant, then make it fast.  :)
    #
    #   Currently only does half the matrix, so no bidireectional rendundant
    #    comparisons are made (and memory/time wasted).  Accession methods
    #    keep track of this.
    sub _calculate_point_distance_matrix {
         my ($self, %args) = @_;

         ## prevents us from repeating reverse calculations already done.         
         my %compared = ();

         ## this is expensive, and perhaps not practical for large maps
         for my $shape1 ( sort {$a->id cmp $b->id} @{$self->shapes} ) {
            my $shape1_id = $shape1->id;
            next unless ( $shape1_id =~ /cut_(\d+)/ && $1 <= 5 );
         
            for my $shape2 ( sort {$a->id cmp $b->id} @{$self->shapes} ) { 
                my $shape2_id = $shape2->id;
                
                next unless ( $shape2_id =~ /cut_(\d+)/ && $1 <= 5 );
               
                ## distance between points in the same shape aren't needed
                next if ( $shape1->id eq $shape2->id );
                
                ## has the inverse already been compared?
                if ( exists $compared{$shape2_id} && exists $compared{$shape2_id}{$shape1_id} ) {
                    print "skipping already compared $shape1_id and $shape2_id\n";
                    next;
                } else {
                    print "doing matrix calculations on $shape1_id vs $shape2_id\n";
                    $compared{$shape1_id}{$shape2_id} = 1;
                }
                
                $shape1->calculate_neighbor_distances( $shape2 );
            }
         }
    }
    
    sub _parse_svg_file {
        my ($self, %args) = @_;
        my $shapes = [];
        
        my $twig = XML::Twig->new(
            twig_roots => {
                g => sub {
                        my ($t, $elt) = @_;
                        $self->_process_group( $elt, $shapes );
                     },
            },
        );
        
        $twig->parsefile( $args{path} );
        
        $self->set_shapes( $shapes );
        $self->set_source( 'svg' );
    }
    
    sub _process_group {
        my ($self, $g, $shapes) = @_;
        
        ## ignore the transformation groups
        return if ( $g->att('transform') );
        
        ## we expect a 'style' definition here
        my $shape_id;
        
        if ( $g->att('style') ) {
            $shape_id = $g->att('style');
        } else {
            croak("ERROR: expected non-transform g element to have a style attribute");
        }
        
        for my $polyline ( $g->children('polyline') ) {
            my $shape = $self->_process_polyline( $polyline );
            push @$shapes, $shape;
        }
    }
    
    sub _process_polyline {
        my ( $self, $polyline ) = @_;
        my ( $style, $points );
        my ( $stroke_width, $has_internal );

        if ( $polyline->att('style') ) {
            $style = $polyline->att('style');
        } else {
            croak("style is a required non-transform polyline attribute");
        }
        
        if ( $polyline->att('points') ) {
            $points = $polyline->att('points');
        } else {
            croak("points is a required non-transform polyline attribute");
        }
        
        if ( $style =~ /stroke\-width\:([0-9.]+)/ ) {
            $stroke_width = $1;
        } else {
            croak("expected polyline style attribute to contain stroke-width");
        }
        
        my $id;
        
        if ( $style =~ /outline\:(\d+)/ ) {
            $has_internal = 1;
            $id = "outline_$1";

        } elsif ( $style =~ /cut\:(\d+)/ ) {
            $has_internal = 0;
            $id = "cut_$1";

        } else {
            croak("expected polyline style attribute to have either 'outline' or 'cut'");
        }
        
        ## holds pairs of points as they are parsed and before they are added to a shape
        my @points = ();
        my @cursor = ();
        
        while ( $points =~ /([0-9\.]+)/g ) {
            push @cursor, $1;
            
            if ( scalar @cursor == 2 ) {
                push @points, [ $cursor[0], $cursor[1] ];
                @cursor = ();
            }
        }

        ## build a Shape out of the attributes we parsed
        my $shape = new Cutter::Map::Shape(
                        id => $id,
                        width => $stroke_width,
                        has_internal_shapes => $has_internal,
                        points => \@points,
                    );

        return $shape;
    }
    
}

1==1;
