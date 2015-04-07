#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;

use File::Assets::Precompile;

use FindBin;
require "$FindBin::Bin/common.pl";

my $fap = File::Assets::Precompile->new(
    'base_path'   => "$FindBin::Bin/assets/",
    'output_path' => "$FindBin::Bin/public/assets/",
    #'minify'      => 1,

    #'base_url'    => 'https://cdn.example.com/public/assets/',
    'base_url'         => '/public/assets/',
    'development_mode' => 1,
);
ok( $fap, 'Got object' );

my $files = $fap->asset_cache();

#diag explain $fap->asset_cache;
$fap->copy_files();

diag explain $fap->asset_cache;
diag 'Full Digest: ', $fap->full_digest->hexdigest;
for my $file ( keys %{$files} ) {
    diag $fap->asset_url($file);
}
1;
