# EasyLog.pm
# (C) 2007 Valent Internet Solutions, LLC
#

package Util::EasyLog;
use strict;
require 5.6.0;

$Util::EasyLog::VERSION = "1.0";

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $m = {};
	bless ($m, $class);
	return $m unless $m->{PERSIST};

	return $m;
}

sub debug
{
	my $m = shift;
	print "DEBUG: ", join( ' ', @_ ), "\n";
}
sub info
{
	my $m = shift;
	print "INFO: ", join( ' ', @_ ), "\n";
}
sub warn
{
	my $m = shift;
	print "WARN: ", join( ' ', @_ ), "\n";
}
sub error
{
	my $m = shift;
	print "ERROR: ", join( ' ', @_ ), "\n";
}

1;  # so the require or use succeeds

__END__
