package Cutter;

=head1 NAME

Cutter.pm - A class for representing planar cutters (like owhite's laser)

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=over 3

=item I<PACKAGE>->new( type => I<'laser'> )

Returns a newly created "Cutter" object.

=item I<$OBJ>->load_map( path => I<'/path/to/some.svg'> )

Parses a SVN map file and returns a Cutter::Map object.

=back

=head1 AUTHOR

    Joshua Orvis
    jorvis@users.sf.net

=cut

use strict;
use Carp;
use Cutter::Map;

## class data and methods
{

    my %_attributes = (
                        type  => undef,
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
    
    sub load_map {
        my ($self, %args) = @_;
        
        if ( ! exists $args{path} ) {
            croak("The load_map method requires a path argument");
        }
        
        my $map = Cutter::Map->new();
           $map->parse_from_svg( path => $args{path} );
        
        return $map;
    }
    
    ## accessors
    sub type { return $_[0]->{type} }

    
}

1==1;

