#!/usr/bin/perl

use strict;
use warnings;
use CFS::DB;
use Rose::DB::Object::Loader;

sub mk_path($);

my $loader = Rose::DB::Object::Loader->new(db => CFS::DB->new(),
             class_prefix => 'CFS');
my @classes = $loader->make_classes(include_views => 1, require_primary_key => 0);

foreach my $class (@classes)
{
	my $file = scalar $class;
	my $path = '';
	if ( $file =~ s/^(.*)::([^:]+)$/$2/o ) {
		$path = $1;
		$path =~ s/::/\//go;
	}

	mk_path($path);
	open PM, '>', "$path/$file.pm"
		or die "open($path/$file.pm) failed: $!\n";

	if($class->isa('Rose::DB::Object')) {
		print PM $class->meta->perl_class_definition(indent => 2), "\n";

	# Rose::DB::Object::Manager subclasses
	} else {
		print PM $class->perl_class_definition, "\n";
	}
	close PM;
}

sub mk_path($) {

	my $dir = shift or return;
	my $base = '.';

	foreach my $d ( split /\//, $dir ) {
		unless ( -d "$base/$d" ) {
			mkdir "$base/$d" or warn "mkdir($base/$d) failed: $!\n";
		}
		$base .= "/$d";
	}
}
