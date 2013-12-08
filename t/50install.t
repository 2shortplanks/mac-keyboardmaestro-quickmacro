#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
unless ($ENV{POD_TESTS} || $ENV{PERL_AUTHOR} || $ENV{THIS_IS_MARKF_YOU_BETCHA}) {
    Test::More::plan(
        skip_all => "Test::Pod tests not enabled (set POD_TESTS or PERL_AUTHOR env var)"
    );
}

Test::More::plan( tests => 1 );

use Mac::KeyboardMaestro::QuickMacro;

my $quick = Mac::KeyboardMaestro::QuickMacro->new(
	author_identifier => "Mac::KeyboardMaestro::QuickMacro test suite",
);

my $n = int rand(10000);

# install the macro
$quick->quick_macro("com.twoshortplanks.quickmacrotest", $n);

ok(1);
