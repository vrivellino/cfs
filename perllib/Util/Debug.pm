# Debug.pm
# (C) 2005 Valent Internet Solutions, LLC
#

package Util::Debug;
use strict;
require 5.6.0;

$Util::Debug::VERSION = "1.0";

sub new
{
	my $proto = shift;
	my %args = @_;
	my $class = ref($proto) || $proto;

	my $m;
	$m->{FILE} = $args{File} || '/tmp/perl-util.debug';
	$m->{LEVEL} = $args{Level} || 1;
	$m->{PERSIST} = $args{Persist};
	$m->{_OPEN_} = 0;

	bless ($m, $class);
	return $m unless $m->{PERSIST};

	# open the debug file
	if ( CORE::open( DEBUGFILE, '>>', $m->{FILE} ) )
	{
		$m->{_OPEN_} = 1;
		$m->{_FH_} = *DEBUGFILE;
		$m->out( "Now debugging at level ", $m->{LEVEL} );
	}
	else
		{ print( STDERR "Error opening debug file ", $m->{FILE}, ": $!\n" ); }

	return $m;
}

sub close
{
	my $m = shift or return;
	return unless $m->{OPEN};
	local *DEBUGFILE = $m->{_FH_};
	close( DEBUGFILE );
	$m->{_OPEN_} = 0;
	$m->{_FH_} = undef;
}

sub DESTROY
{
	my $m = shift or return;
	$m->close;
}

sub out
{
	my $m = shift or return;
	return unless defined $_[0] && $m->{LEVEL};
	local *DEBUGFILE = $m->{_FH_} if defined $m->{_FH_};
	CORE::open( DEBUGFILE, '>>', $m->{FILE} ) unless $m->{_OPEN_};

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( time );
	my @months = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );

	CORE::printf( DEBUGFILE "%s %2d %02d:%02d:%02d  ", $months[$mon], $mday, $hour, $min, $sec );
	CORE::print( DEBUGFILE @_, "\n" );
	CORE::close( DEBUGFILE ) unless $m->{PERSIST} || ! $m->{_OPEN_};
}

sub level
{
	my $m = shift or return;
	my $lvl = shift;
	if (( defined $lvl )&&( $lvl >= 0 ))
	{
		$m->{LEVEL} = shift;
		$m->out( "Now debugging at level ", $m->{LEVEL} );
	}
	return $m->{LEVEL};
}

sub info
{
	my $m = shift or return;
	return $m->{LEVEL} >= 1;
}

sub notice
{
	my $m = shift or return;
	return $m->{LEVEL} >= 2;
}

sub verbose
{
	my $m = shift or return;
	return $m->{LEVEL} >= 3;
}

sub crazy
{
	my $m = shift or return;
	return $m->{LEVEL} >= 5;
}

1;  # so the require or use succeeds

__END__
