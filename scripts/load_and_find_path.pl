#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Cutter;

my $svg_file = shift || die "pass me an SVN map file";

my $cutter = Cutter->new( type => 'laser' );
   $cutter->load_map( path => $svg_file );

