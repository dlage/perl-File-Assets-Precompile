use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'File::Assets::Precompile',
    AUTHOR             => q{Dinis Lage <dlage@cpan.org>},
    VERSION_FROM       => 'lib/File/Assets/Precompile.pm',
    ABSTRACT_FROM      => 'lib/File/Assets/Precompile.pm',
    LICENSE            => 'artistic_2',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0, },
    BUILD_REQUIRES     => { 'Test::More' => 0, },
    PREREQ_PM          => {
        'JavaScript::Minifier::XS' => 0,
        'Path::Class'              => 0,
        'CSS::Minifier::XS'        => 0,
        'Log::Log4perl'            => 0,

        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'File-Assets-Precompile-*' },
);
