#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Cutter;

my $svg_file = shift || die "pass me an SVN map file";

my $cutter = Cutter->new( type => 'laser' );
my $map = $cutter->load_map( path => $svg_file );

my $shapes = $map->shapes();
for my $shape ( @$shapes ) {
    my $points = $shape->points();
    
    print "shape (" . $shape->id . ") has " . scalar( @$points ) . " points\n";
}
