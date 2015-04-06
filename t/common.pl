#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init(
    {
        'level'  => $TRACE,
        'layout' => "%r %p %M-%L %m%n",
    },
);

1;
