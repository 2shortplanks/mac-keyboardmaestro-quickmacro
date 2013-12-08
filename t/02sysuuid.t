#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Mac::KeyboardMaestro::QuickMacro;

my $quick = Mac::KeyboardMaestro::QuickMacro->new();
my $uuid = $quick->machine_hardware_uuid;

like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;

