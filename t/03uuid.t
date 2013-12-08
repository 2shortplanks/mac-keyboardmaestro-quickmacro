#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 15;
use Mac::KeyboardMaestro::QuickMacro;

### raw strings ###

# check that we can generate any old uuid with the identifier

{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new();
	my $uuid = $quick->uuid_for_string("foo");
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
}

# check that the uuid stuff is stable

{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new( author_identifier => "foo" );
	my $uuid = $quick->uuid_for_string("foo");
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
	is $uuid, '8B4C67F2-C417-9FDE-D158-9A29F5A2F502';
}
{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new( author_identifier => "bar" );
	my $uuid = $quick->uuid_for_string("foo");
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
	is $uuid, '0A8CB48E-9912-7818-3476-9C5A14A992A8';
}

### triggers ###

{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new();
	my $uuid = $quick->uuid_for_trigger("foo");
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
}

# check that the uuid stuff is stable

{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new( author_identifier => "foo" );
	my $uuid = $quick->uuid_for_trigger("foo");
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
	is $uuid, 'A2755721-DFB6-02B7-E4FA-4CED9E1F7858';
}
{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new( author_identifier => "bar" );
	my $uuid = $quick->uuid_for_trigger("foo");
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
	is $uuid, 'BFA4CA25-D273-145E-FF6F-9D55AB9FA4D8';
}

### gropus ###

{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new();
	my $uuid = $quick->uuid_for_quick_macro_group;
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
}

# check that the uuid stuff is stable

{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new( author_identifier => "foo" );
	my $uuid = $quick->uuid_for_quick_macro_group;
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
	is $uuid, 'CFFC1100-00A1-DADF-E28A-9BCDEDF0FDA3';
}
{
	my $quick = Mac::KeyboardMaestro::QuickMacro->new( author_identifier => "bar" );
	my $uuid = $quick->uuid_for_quick_macro_group;
	like $uuid, qr/\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/;
	is $uuid, '8FB1CA78-4F51-1F52-BC35-DD6238432FF6';
}


