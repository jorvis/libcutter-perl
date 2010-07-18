package Cutter::Map;

=head1 NAME

Cutter::Map - A class for representing a planar cutter map.

=head1 SYNOPSIS


=head1 DESCRIPTION

A planar cutter map is a series of points defining shapes on a plane to 
be cut out of some material.  A map can contain one or more 
Cutter::Map::Shape objects.

=head1 METHODS

=over 3

=item I<PACKAGE>->new( )

Returns a newly created "Cutter::Map" object.

=item I<$OBJ>->parse_from_svg( path => I<'/path/to/some.svg'> )

Parses a SVN map file and returns a Cutter::Map object.

=back

=head1 ASSUMPTIONS

If a polyline has "cut:" in its style attribute, it has no internal pieces

=head1 AUTHOR

    Joshua Orvis
    jorvis@users.sf.net

=cut

use strict;
use Carp;
use Cutter::Map::Shape;
use Cutter::Map::Point;
use XML::Twig;

## class data and methods
{

    my %_attributes = (
                        ## values may be constructed | svg
                        source => undef,
                        
                        ## if parsed from something, here's the source
                        path  => undef,
                        
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
        ##  were all valid
        for (keys %args) {
            if (exists $_attributes{$_}) {
                $self->{$_} = $args{$_};
            } else {
                croak("$_ is not a recognized attribute");
            }
        }
        
        ## initialize any arrays
        $self->{shapes} = [] if ! defined $self->{shapes};
        
        return $self;
    }
    
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
        
        return $self;
    }
    
    ## accessors
    sub source { return $_[0]->{source} }
    sub path   { return $_[0]->{path} }

    ## mutators
    sub set_path   { $_[0]->{path} = $_[1] }
    sub set_shapes { $_[0]->{shapes} = $_[1] }
    sub set_source { $_[0]->{source} = $_[1] }
    
    
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
        
        if ( $style =~ /outline\:/ ) {
            $has_internal = 1;

        } elsif ( $style =~ /cut\:/ ) {
            $has_internal = 0;

        } else {
            croak("expected polyline style attribute to have either 'outline' or 'cut'");
        } 
        
        my $shape = new Cutter::Map::Shape();
        
        return $shape;
    }
    
}

1==1;




















