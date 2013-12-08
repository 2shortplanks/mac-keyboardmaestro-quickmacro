package Mac::KeyboardMaestro::QuickMacro;

use strict;
use warnings;

use File::Temp qw(tempfile);
use Digest::MD5 qw(md5_hex);
use Carp qw(croak);

=head1 NAME

Mac::KeyboardMaestro::QuickMacro - create quick typed text trigger macros

=head1 SYNOPSIS

   my $qm = Mac::KeyboardMaestro::QuickMacro->new(
     author_identifier => 'mark@twoshortplanks.com'
   );

   # install a macro that replaces mf;; with Mark Fowler
   $qm->quick_macro( 'mf;;' => "Mark Fowler" );

=head1 DESCRIPTION

Quickly install a typed text trigger macro into Keyboard Maestro that
simply inserts replacement text.

=head2 Constructor

=over

=item new(@args)

Takes the accessors below as arguments.

=cut

sub new {
	my $class = shift;
	return bless { @_ }, $class;
}

=back

=head2 Accessors

Read only accessors.  Values may be via assigned to the constructor when you
create the instance

=over

=item author_identifier

A unique identifier for the author of the macro.  It is recommended that you
use a email address or URI you control.

The identifier isn't stored in the resulting macro, but the identifier is used
(along with the trigger text and module salt) to calculate the consistent
UUID for each macro.  As such it's non-trivial to recover the identifer from
the macro (so you probably don't have to worry about spammers if you use your
email address) but not impossible since this module only uses the relativley
weak UUID

If you don't supply a value to this then the MacUUID (the unique value Keyboard
Maestro assigns to each mac) is used.  This ensures that macros you create don't
conflict with those created by other authors on other machines, but it does mean
that macros created by you on seperate devics and then synced together will
not necessarily override each other as you might expect.

=cut

sub author_identifier {
	my $self = shift;
	$self->{author_identifier} ||= $self->machine_hardware_uuid;
	return $self->{author_identifier};
}

=head2 Methods

=over

=item quick_macro( $trigger, $replacement_text )

Install a macro in Keyboard Maestro that replaces the trigger text with
the replacment text whenever it is typed.

The trigger text is case sensitive, and the replacement text is inserted
via pasting.

=cut

sub quick_macro {
	my $self = shift;

	my $trigger = shift;
	my $replacement_text = shift;

	unless (length($trigger)) {
		croak "Invalid trigger when calling quick_macro";
	}
	unless (defined($replacement_text)) {
		croak "Invalid replacement text passwed when calling quick_macro";
	}

	my $bytes = $self->generate_xml($trigger, $self->escape_km($replacement_text));
	$self->install_macro( $bytes );

	return;
}

=back

=head2 Overridabe Methods

These methods are used by the macro generation process;  Documented here
in case someone wants to override them in the subclass.

=over

=item machine_hardware_uuid

Work out the machine uuid.  This is currently used as the default author
identifier.

Currently works by shelling out to ioreg and parsing the output with a regex.

=cut

sub machine_hardware_uuid {
	open my $pfh, '-|', 'ioreg','-rd1','-c','IOPlatformExpertDevice'
		or croak "Can't run ioreg to find machine uuid: $!";

	while (<$pfh>) {
		if (/\A\s*"IOPlatformUUID" = "([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})"/) {
			return $1;
		}
	}

	croak "Can't determine machine's UUID"
}

=item module_salt

Returns per module salt;  This is simply a constant random string used in the
uuid generation process (it's contatinated onto whatever string we md5) to allow
subclasses (or things using identical hash techniques) to generate non clashing
uuids if they want.

=cut

# think really hard before changing this
sub module_salt { return "8828A75A-07A1-4C63-B83B-AC6A7031A49F" }

=item uuid_for_string($str)

Creates a uuid from the passed string.  Uses the module salt and the
author identifier.



=cut

sub uuid_for_string {
	my $self = shift;
	my $str = shift;

	my $author_identifier = $self->author_identifier;
	my $salt = $self->module_salt;

	$str = md5_hex( "$str|$author_identifier|$salt" );

	# turn the md5 into a UUID format

	# first uppercase
	$str = uc($str);

	# then insert the dashes
	# AAB70039-90B0-4688-9548-D56282D15A5F
	# 012345567890123456789012
	substr($str,8,0,"-");
	substr($str,13,0,"-");
	substr($str,18,0,"-");
	substr($str,23,0,"-");

	return $str;
}


=item uuid_for_quick_macro_group

Returns the UUID for the group that the quick macro group is in.  This varies
depending on what your author_identifier is.

=cut

sub uuid_for_quick_macro_group {
	my $self = shift;
	return $self->uuid_for_string("group");
}

=item uuid_for_trigger( $trigger )

Creates a unique identifer for a given trigger.  This is always
consistent every time it is called (assuming that) 

=cut

sub uuid_for_trigger {
	my $self = shift;
	my $trigger = shift;

	return $self->uuid_for_string("macro|$trigger");
}

=item generate_xml($trigger, $replacement_string)

Returns an XML byte string.

=cut

sub generate_xml {
	my $self = shift;

	my $trigger = shift;
	my $string = shift;

	my $group_uuid = $self->uuid_for_quick_macro_group;
	my $macro_uuid = $self->uuid_for_trigger( $trigger );

	$trigger = $self->escape_xml( $trigger );
	$string  = $self->escape_xml( $string );

	my $name = "Quick Macro $trigger";

	my $time = 408166570.270639;  # todo, work out what this means

	# yeah, we don't actually need a real XML engine for this.
	# use a frickin' heredoc
	return <<"XML";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<dict>
		<key>Activate</key>
		<string>Normal</string>
		<key>IsActive</key>
		<true/>
		<key>Macros</key>
		<array>
			<dict>
				<key>Actions</key>
				<array>
					<dict>
						<key>Action</key>
						<string>ByPasting</string>
						<key>IsActive</key>
						<true/>
						<key>IsDisclosed</key>
						<true/>
						<key>MacroActionType</key>
						<string>InsertText</string>
						<key>Paste</key>
						<true/>
						<key>Text</key>
						<string>$string</string>
					</dict>
				</array>
				<key>IsActive</key>
				<true/>
				<key>ModificationDate</key>
				<real>$time</real>
				<key>Name</key>
				<string>$name</string>
				<key>Triggers</key>
				<array>
					<dict>
						<key>Case</key>
						<string>Exact</string>
						<key>MacroTriggerType</key>
						<string>TypedString</string>
						<key>OnlyAfterWordBreak</key>
						<false/>
						<key>SimulateDeletes</key>
						<true/>
						<key>TypedString</key>
						<string>$trigger</string>
					</dict>
				</array>
				<key>UID</key>
				<string>$macro_uuid</string>
			</dict>
		</array>
		<key>Name</key>
		<string>Quick Macros</string>
		<key>UID</key>
		<string>$group_uuid</string>
	</dict>
</array>
</plist>
XML
}

=item escape_xml( $chars )

Escapes the XML.  In a nushell:  Replaces C<&> with C<&amp;>, C<< < >> with
C<&lt;> and turn anything that isn't ASCII into ASCII by doing entity encoding.

Doesn't escape any quotes.  Don't use this to protect text you're putting
in attributes.

=cut

sub escape_xml {
	my $self = shift;
	my $str = shift;
	$str =~ s/&/&amp;/g;
	$str =~ s/</&lt;/g;
	$str =~ s/([^\x{00}-\x{7f}])/sprintf "&#x%X;", ord($1)/ge;
	return $str;
}

=item escape_km( $string )

Escapes the string so that Keyboard Maestro doesn't do anything special with
any of the characters contain within it.

=cut

sub escape_km {
	my $self = shift;
	my $str = shift;
	$str =~ s/\\/\\\\/g;
	$str =~ s/\%/\%\%/g;
	return $str;
}

=item install_macro( $bytes )

Installs the macro represented by the XML into the system

=cut

sub install_macro {
	my $self = shift;
	my $bytes = shift;

	my ($fh, $filename) = tempfile( "X"x16, SUFFIX => '.kmmacros');
	print $fh $bytes;
	close $fh;

	print $bytes;

	system("open", $filename);

	# todo, we should delete the temp file, but I have no way of knowing if
	# keyboard maestro has had time to read it yet.

	return;
}

=back

=head1 BUGS

This module could be a lot more powerful, but it's designed to be simple.  One
of the key objectives of this module was to have zero external non-core
dependancies.  As such it does not generate XML with an XML library, but rather
assembles one from strings, and this puts contraints on what this does.

=head1 

=cut

1;

