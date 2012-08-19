# Error.pm
# (C) 2005 Valent Internet Solutions, LLC
#

package Util::Error;
use strict;
require 5.6.0;

$Util::Error::VERSION = "1.0";

sub new
{
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $m;
	$m->{FLAG} = 0;
	$m->{STR} = '';

	bless ($m, $class);
	return $m;
}

sub reset
{
	my $m = shift or return;
	$m->{FLAG} = 0;
	$m->{STR} = '';
}

sub check
{
	my $m = shift or return;
	my $f = $m->{FLAG};
	$m->{FLAG} = 0 if ! @_ ;
	return $f;
}

sub string
{
	my $m = shift or return;
	if ( @_ )
	{
		$m->{STR} = join( '', @_ );
		$m->{FLAG} = 1;
	}
	return $m->{STR};
}

1;  # so the require or use succeeds

__END__
