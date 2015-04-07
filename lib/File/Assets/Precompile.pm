package File::Assets::Precompile;
{
    $File::Assets::Precompile::VERSION = '0.0.1';
}

use 5.006;
use strict;
use warnings;

use Log::Log4perl;
my $l = Log::Log4perl::get_logger();

=head1 NAME

File::Assets::Precompile - The great new File::Assets::Precompile!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use File::Assets::Precompile;

    my $foo = File::Assets::Precompile->new(
        'base_path'   => "$FindBin::Bin/assets/",
        'output_path' => "$FindBin::Bin/public/assets/",

        #'base_url'    => 'https://cdn.example.com/public/assets/',
        'base_url'         => '/public/assets/',
        'development_mode' => 1,
    );
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS
=cut

use Moose;
use namespace::autoclean;

use Carp qw( croak );
use Data::Dumper;
use File::Basename qw();
use File::Find;
use File::MMagic;
use Path::Class;
use Path::Class::Dir;
use Path::Class::File;

use Digest;
use JavaScript::Minifier::XS;
use CSS::Minifier::XS;

has 'base_path' => (
    'is'  => 'rw',
    'isa' => 'Str',
);

has 'output_path' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'digest_method' => (
    'is'      => 'ro',
    'isa'     => 'Str',
    'default' => 'MD5',
);

has 'full_digest' => (
    'is'         => 'ro',
    'lazy_build' => 1,
);

has 'asset_cache' => (
    'is'         => 'ro',
    'isa'        => 'HashRef',
    'init_arg'   => undef,
    'lazy_build' => 1,
    'traits'     => ['Hash'],
    'handles'    => {
        'asset_cache_values' => 'values',
        'asset_cache_count'  => 'count',
        'asset_cache_keys'   => 'keys',
    },
);

has 'base_url' => (
    'is'       => 'rw',
    'isa'      => 'Str',
    'required' => 1,
);

has 'development_mode' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'versionized_extensions' => (
    'is'         => 'ro',
    'isa'        => 'HashRef',
    'lazy_build' => 1,
);

has 'minify' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

sub _build_versionized_extensions {
    my $self = shift;
    return {
        '.css' => 1,
        '.js'  => 1,
    };
}

=head2 _build_full_digest

=cut

sub _build_full_digest {
    my $self   = shift;
    my $digest = Digest->new( $self->digest_method );
    return $digest;
}

=head2 _build_asset_cache

=cut

sub _build_asset_cache {
    my $self  = shift;
    my $files = $self->find_files();
    return $files;
}

=head2 md5sum
=cut

sub calculate_fingerprint {
    my $self = shift;
    my %args = @_;

    my $file   = $args{'file'};
    my $data   = $args{'data'};
    my $digest = Digest->new( $self->digest_method );

    if ($file) {
        open my $fh, '<:raw', $file;
        $digest->addfile($fh);
        close($fh);
    }

    if ($data) {
        $digest->add($data);
    }

    return $digest->hexdigest;
}

sub _file_mtime {
    my $file  = shift;
    my $mtime = [ stat($file) ]->[9];
    return $mtime;
}

sub _metadata_from_file {
    my $self      = shift;
    my $full_path = shift;
    if ( !-f $full_path ) {
        return;
    }
    my $file = Path::Class::File->new($full_path);
    my $rel_path = File::Spec->abs2rel( $file, $self->base_path );

    my $fingerprint = $self->calculate_fingerprint( 'file' => $file, );
    my $ft          = File::MMagic->new();
    my $mime_type   = $ft->checktype_filename( $file->absolute );

    my ( $filename, $dirs, $suffix ) =
      File::Basename::fileparse( $rel_path, qr/\.[^.]*/ );

    $self->full_digest->add( $rel_path, $fingerprint, );
    return {
        'full_path'   => $full_path,
        'rel_path'    => $rel_path,
        'fingerprint' => $fingerprint,
        'mtime'       => 0,
        'mime_type'   => $mime_type,
        'suffix'      => $suffix,
        'filename'    => $filename,
        'dirs'        => $dirs,
    };
}

sub find_files {
    my $self = shift;
    my %args = @_;

    my %file_cache;
    my $wanted = sub {
        my $full_path = $File::Find::name;
        my $res       = $self->_metadata_from_file($full_path);
        if ( !$res ) {
            return;
        }
        $file_cache{ $res->{'rel_path'} } = $res;
    };
    find( $wanted, $self->base_path, );
    return \%file_cache;
}

sub copy_files {
    my $self = shift;
    my %args = @_;

    # Make sure cache is initialized before full_digest request
    my $asset_cache = $self->asset_cache;

    my $aggregate_digest = $self->full_digest->hexdigest;

    my $output_path = Path::Class::Dir->new( $self->output_path );
    $output_path->rmtree();

    $l->info( 'Copying ', $self->asset_cache_count, ' files', );
    for my $value ( $self->asset_cache_values ) {
        $self->_process_file($value);
    }
    return;
}

sub _process_file {
    my $self     = shift;
    my $asset    = shift;
    my $rel_path = $asset->{'rel_path'};

    my $filename = $asset->{'filename'};
    my $dirs     = $asset->{'dirs'};
    my $suffix   = $asset->{'suffix'};
    my $dest_dir = Path::Class::Dir->new( $self->output_path, $dirs, );

    my $dest_filename = $filename . $suffix;

    my $file  = Path::Class::File->new( $asset->{'full_path'}, );
    my $mtime = _file_mtime($file);

    if ( !-d $dest_dir ) {
        $dest_dir->mkpath;
    }

    $asset->{'mtime'} = $mtime;

    #$l->debug( 'Getting file: ', { 'filter' => \&Dumper, 'value' => $file, }, );
    my $content = $self->_get_content(
        'asset'         => $asset,
        'original_file' => $file,
    );

    if ( $asset->{'mime_type'} eq 'text/plain' ) {
        $content = $self->_replace_asset_references(
            'asset'   => $asset,
            'content' => $content,
        );
    }

    if ( $asset->{'dirty_fingerprint'} ) {
        $asset->{'fingerprint'} =
          $self->calculate_fingerprint( 'data' => $content, );
    }

    my $fingerprint = $asset->{'fingerprint'};

    #if ( $self->versionized_extensions->{$suffix} ) {
    $dest_filename = sprintf( '%s-%s%s', $filename, $fingerprint, $suffix, );

    #}

    my $dest_file = Path::Class::File->new( $dest_dir, $dest_filename, );

    my $target_rel_path = File::Spec->abs2rel( $dest_file, $self->output_path );
    $asset->{'dest_rel_path'} = $target_rel_path;
    $asset->{'dest_path'}     = $dest_file->stringify;

    $dest_file->spew($content);

    return;
}

sub _replace_asset_references {
    my $self = shift;
    my %args = @_;

    my $asset   = $args{'asset'};
    my $content = $args{'content'};

    my $base_path = my $full_path =
      File::Basename::dirname( $asset->{'full_path'} );

    my $total_subs = 0;
    for my $asset_ref ( $self->asset_cache_values ) {
        my $rel_path_to_ref =
          File::Spec->abs2rel( $asset_ref->{'full_path'}, $base_path, );

        my $suffix      = $asset_ref->{'suffix'};
        my $fingerprint = $asset_ref->{'fingerprint'};

        my $target_ref = $rel_path_to_ref;
        $target_ref =~ s/$suffix$/-${fingerprint}${suffix}/g;

        my $count_changes = $content =~ s/$rel_path_to_ref/$target_ref/g;

        next unless $count_changes;
        $total_subs += $count_changes;
        $l->debug( 'Changed "', $rel_path_to_ref, '" to "', $target_ref, '" ',
            $count_changes, ' times.', );
    }

    if ($total_subs) {
        $asset->{'dirty_fingerprint'} = 1;
        $l->debug( 'Made ', $total_subs, ' changes in asset: ',
            $asset->{'full_path'}, );
    }

    return $content;
}

sub _get_content {
    my $self = shift;
    my %args = @_;

    my $asset         = $args{'asset'};
    my $original_file = $args{'original_file'};

    my $original = $original_file->slurp();

    if ( !$self->minify ) {
        return $original;
    }

    my $minified;

    if ( $asset->{'suffix'} eq '.css' ) {
        $minified = CSS::Minifier::XS::minify($original);
    }

    if ( $asset->{'suffix'} eq '.js' ) {
        $minified = JavaScript::Minifier::XS::minify($original);
    }

    return $minified || $original;
}

sub _check_refresh_file {
    my $self  = shift;
    my $asset = shift;
}

sub _get_asset {
    my $self            = shift;
    my $asset_requested = shift;

    my $asset = $self->asset_cache->{$asset_requested};
    if ( !$self->development_mode ) {
        return $asset;
    }

    my $mtime = _file_mtime( $asset->{'full_path'} );
    if ( !$asset or ( $mtime != $asset->{'mtime'} ) ) {

        # Treat as a new file
        my $full_path =
          Path::Class::File->new( $self->base_path, $asset_requested, );
        $asset = $self->_metadata_from_file($full_path);
        if ( !$asset ) {

            # File not found
            return;
        }

        $self->_process_file($asset);
        $self->asset_cache->{ $asset->{'rel_path'} } = $asset;
    }

    return $asset;
}

sub asset_url {
    my $self            = shift;
    my $asset_requested = shift;

    my $asset = $self->_get_asset($asset_requested);
    if ( !$asset ) {

        # TODO Asset not found... log error
        return $asset_requested;
    }

    my $uri = $self->base_url . $asset->{'dest_rel_path'};
    return $uri;
}

=head1 AUTHOR

Dinis Lage, C<< <dlage at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-assets-precompile at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Assets-Precompile>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::Assets::Precompile


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Assets-Precompile>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/File-Assets-Precompile>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/File-Assets-Precompile>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Assets-Precompile/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Dinis Lage.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of File::Assets::Precompile
