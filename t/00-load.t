#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'File::Assets::Precompile' ) || print "Bail out!\n";
}

diag( "Testing File::Assets::Precompile $File::Assets::Precompile::VERSION, Perl $], $^X" );
