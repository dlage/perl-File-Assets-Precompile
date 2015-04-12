#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

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

#diag explain $fap->asset_cache;
$fap->copy_files();

my %expected_result = expected_result();

my $files = $fap->asset_cache();

diag explain $files;
diag 'Full Digest: ', $fap->full_digest->hexdigest;
for my $key ( keys %expected_result ) {
    for my $file_key ( keys %{ $expected_result{$key} } ) {
        is(
            $files->{$key}->{$file_key},
            $expected_result{$key}->{$file_key},
            "$key has same $file_key",
        );
    }
}

$fap->clean_output();
done_testing();

sub expected_result {
    return (
        'bootstrap-3.3.4-dist/css/bootstrap-theme.css' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/css/bootstrap-theme-53ebfaed3b2da023bda7a9c051bc2dc8.css',
            'dirs'              => 'bootstrap-3.3.4-dist/css/',
            'dirty_fingerprint' => 1,
            'filename'          => 'bootstrap-theme',
            'fingerprint'       => '53ebfaed3b2da023bda7a9c051bc2dc8',
            'mime_type' => 'text/plain',
            'rel_path'  => 'bootstrap-3.3.4-dist/css/bootstrap-theme.css',
            'suffix'    => '.css'
        },
        'bootstrap-3.3.4-dist/css/bootstrap.css' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/css/bootstrap-0430bdc84aa2e3c6e4f0c260203551c1.css',
            'dirs'              => 'bootstrap-3.3.4-dist/css/',
            'dirty_fingerprint' => 1,
            'filename'          => 'bootstrap',
            'fingerprint'       => '0430bdc84aa2e3c6e4f0c260203551c1',
            'mime_type' => 'text/plain',
            'rel_path'  => 'bootstrap-3.3.4-dist/css/bootstrap.css',
            'suffix'    => '.css'
        },
        'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.eot' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular-f4769f9bdb7466be65088239c12046d1.eot',
            'dirs'        => 'bootstrap-3.3.4-dist/fonts/',
            'filename'    => 'glyphicons-halflings-regular',
            'fingerprint' => 'f4769f9bdb7466be65088239c12046d1',
            'mime_type' => 'application/octet-stream',
            'rel_path' =>
              'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.eot',
            'suffix' => '.eot'
        },
        'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.svg' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular-89889688147bd7575d6327160d64e760.svg',
            'dirs'        => 'bootstrap-3.3.4-dist/fonts/',
            'filename'    => 'glyphicons-halflings-regular',
            'fingerprint' => '89889688147bd7575d6327160d64e760',
            'mime_type' => 'text/plain',
            'rel_path' =>
              'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.svg',
            'suffix' => '.svg'
        },
        'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.ttf' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular-e18bbf611f2a2e43afc071aa2f4e1512.ttf',
            'dirs'        => 'bootstrap-3.3.4-dist/fonts/',
            'filename'    => 'glyphicons-halflings-regular',
            'fingerprint' => 'e18bbf611f2a2e43afc071aa2f4e1512',
            'mime_type' => 'application/octet-stream',
            'rel_path' =>
              'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.ttf',
            'suffix' => '.ttf'
        },
        'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.woff' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular-fa2772327f55d8198301fdb8bcfc8158.woff',
            'dirs'        => 'bootstrap-3.3.4-dist/fonts/',
            'filename'    => 'glyphicons-halflings-regular',
            'fingerprint' => 'fa2772327f55d8198301fdb8bcfc8158',
            'mime_type' => 'application/octet-stream',
            'rel_path' =>
              'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.woff',
            'suffix' => '.woff'
        },
        'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.woff2' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular-448c34a56d699c29117adc64c43affeb.woff2',
            'dirs'        => 'bootstrap-3.3.4-dist/fonts/',
            'filename'    => 'glyphicons-halflings-regular',
            'fingerprint' => '448c34a56d699c29117adc64c43affeb',
            'mime_type' => 'application/octet-stream',
            'rel_path' =>
              'bootstrap-3.3.4-dist/fonts/glyphicons-halflings-regular.woff2',
            'suffix' => '.woff2'
        },
        'bootstrap-3.3.4-dist/js/bootstrap.js' => {
            'dest_rel_path' =>
'bootstrap-3.3.4-dist/js/bootstrap-9cb0532955cf4d4fb43f792ce0f87227.js',
            'dirs'        => 'bootstrap-3.3.4-dist/js/',
            'filename'    => 'bootstrap',
            'fingerprint' => '9cb0532955cf4d4fb43f792ce0f87227',
            'mime_type' => 'text/plain',
            'rel_path'  => 'bootstrap-3.3.4-dist/js/bootstrap.js',
            'suffix'    => '.js'
        },
        'bootstrap-3.3.4-dist/js/npm.js' => {
            'dest_rel_path' =>
              'bootstrap-3.3.4-dist/js/npm-ccb7f3909e30b1eb8f65a24393c6e12b.js',
            'dirs'        => 'bootstrap-3.3.4-dist/js/',
            'filename'    => 'npm',
            'fingerprint' => 'ccb7f3909e30b1eb8f65a24393c6e12b',
            'mime_type' => 'text/plain',
            'rel_path'  => 'bootstrap-3.3.4-dist/js/npm.js',
            'suffix'    => '.js'
          }
    );
}

1;
