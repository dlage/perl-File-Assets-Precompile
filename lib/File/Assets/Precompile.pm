package File::Assets::Precompile;

use 5.006;
use strict;
use warnings;

=head1 NAME

File::Assets::Precompile - The great new File::Assets::Precompile!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use File::Assets::Precompile;

    my $foo = File::Assets::Precompile->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS
=cut

use Moose;
use namespace::autoclean;

use File::Basename qw();
use File::Find;
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

has 'asset_cache' => (
    'is'         => 'rw',
    'isa'        => 'HashRef',
    'init_arg'   => undef,
    'lazy_build' => 1,
);

=head2 function1

=cut

sub function1 {
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

    my $file = $args{'file'};
    open my $fh, '<:raw', $file;
    my $digest = Digest->new( $self->digest_method );
    $digest->addfile($fh);
    close($fh);

    return $digest->hexdigest;
}

sub find_files {
    my $self = shift;
    my %args = @_;

    my %file_cache;
    my $wanted = sub {
        my $full_path = $File::Find::name;
        if ( !-f $full_path ) {
            return;
        }
        my $file     = Path::Class::File->new($full_path);
        my $rel_path = File::Spec->abs2rel( $file, $self->base_path );
        my $mtime    = [ stat($file) ]->[9];

        my ( $filename, $dirs, $suffix ) = File::Basename::fileparse($rel_path,'\..*');
        my $dest_dir = Path::Class::Dir->new( $self->output_path, $dirs, );
        if ( !-d $dest_dir ) {
            $dest_dir->mkpath;
        }

        my $fingerprint = $self->calculate_fingerprint( 'file' => $file, );

        my $dest_filename =
          sprintf( '%s-%s%s', $filename, $fingerprint, $suffix, );
        my $dest_file = Path::Class::File->new( $dest_dir, $dest_filename, );
        $file->copy_to($dest_file);

        $file_cache{$rel_path} = {
            'full_path'   => $full_path,
            'mtime'       => $mtime,
            'rel_path'    => $rel_path,
            'fingerprint' => $fingerprint,
            'dest_path'   => $dest_file->stringify,
        };
        return;
    };
    find( $wanted, $self->base_path, );
    return \%file_cache;
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
