#!/usr/bin/perl -w

=head1

Notes, the output should be color coded for laser on, off with indicators
of where cuts start and end.  This could be arrows or even pop up info
boxes.  Doable, like this:

http://stackoverflow.com/questions/102457/how-to-create-an-svg-tooltip-like-box

=cut

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Cutter;

my $svg_file = shift || die "pass me an SVN map file";

my $cutter = Cutter->new( type => 'laser' );
my $map = $cutter->load_map( path => $svg_file );

my $shapes = $map->shapes();
for my $shape ( @$shapes ) {
    
    print "shape (" . $shape->id . ") has " . $shape->point_count() . 
          " points.  Has internal: " . $shape->has_internal_shapes . " - Count: (" .
          scalar( @{ $shape->internal_shapes() } ) . ")\n";
}

$cutter->export_cut_xml_from_map( map => $map );
