#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;

use File::Assets::Precompile;
use FindBin;
use File::Spec;

my $fap = File::Assets::Precompile->new(
    'base_path'   => "$FindBin::Bin/assets/",
    'output_path' => "$FindBin::Bin/public/assets/",
);
ok( $fap, 'Got object' );


my $files = $fap->asset_cache();
diag explain $files;
