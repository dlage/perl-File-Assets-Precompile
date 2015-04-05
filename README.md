
#File-Assets-Precompile

[![Build Status](https://travis-ci.org/dlage/perl-File-Assets-Precompile.svg?branch=master)](https://travis-ci.org/dlage/perl-File-Assets-Precompile)

The README is used to introduce the module and provide instructions on
how to install the module, any machine dependencies it may have (for
example C compilers and installed libraries) and any other information
that should be provided before the module is installed.

A README file is required for CPAN modules since CPAN extracts the README
file from a module distribution so that people browsing the archive
can use it to get an idea of the module's uses. It is usually a good idea
to provide version information here so that people can decide whether
fixes for the module are worth downloading.

##TO-DO List 
There are still a lot of things on the way: 
* Compress files - CSS and JS mainly 
* Manifest files - glue together multiple CSS and JS files 
  * Allow separator between files - probably default to `/* filename */`
* Helper method for file urls
  * `asset-url('assets/path/to/asset.png')` would become `public/assets/path/to/asset-version12345678.png`
  * also applied to fonts, etc...

##INSTALLATION

To install this module, run the following commands:

	perl Makefile.PL
	make
	make test
	make install

##USAGE

Example usage:

In your base mojo class:
```perl
my $assets = File::Assets::Precompile->new(
    'base_path'        => $self->home . '/assets/',
    'output_path'      => $self->home . '/public/assets/',
    'base_url'         => '/assets/',
    'development_mode' => 1,
);  
$assets->copy_files();
$self->helper(
    'asset_url' => sub { 
        my $self = shift; 
        $assets->asset_url(@_); 
    }, 
);
```
Then, in you templates:
```perl
<%= link_to 'my versioned asset' => asset_url('bootstrap-3.3.4-dist/js/bootstrap.js') %>
```
##SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc File::Assets::Precompile

You can also look for information at:

    RT, CPAN's request tracker (report bugs here)
        http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Assets-Precompile

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/File-Assets-Precompile

    CPAN Ratings
        http://cpanratings.perl.org/d/File-Assets-Precompile

    Search CPAN
        http://search.cpan.org/dist/File-Assets-Precompile/


##LICENSE AND COPYRIGHT

Copyright (C) 2015 Dinis Lage

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

