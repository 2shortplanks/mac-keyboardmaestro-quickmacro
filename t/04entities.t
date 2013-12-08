#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Mac::KeyboardMaestro::QuickMacro;

my $quick = Mac::KeyboardMaestro::QuickMacro->new();
my $escaped = $quick->escape_xml("L\x{e9}on <3 plant & mathilda");
is $escaped, "L&#xE9;on &lt;3 plant &amp; mathilda";

