#!/usr/bin/perl

use strict;
use warnings;

use CFS::GoogleAPI;
use Data::Dumper;

my $cmd = lc shift || 'list';

my $api = CFS::GoogleAPI->new( model_id => 'CFS20042010v1' ) or die "Something bad happened";

if ( $cmd eq 'list' ) {
	$api->print_model_list();
}

if ( $cmd eq 'get' ) {
	my $res = $api->google_prediction_request('get');
	my $d = Data::Dumper->new([$res]);
	$d->Indent(1);
	print $d->Dump;
}

if ( $cmd eq 'analyze' ) {
	my $res = $api->google_prediction_request('analyze');
	my $d = Data::Dumper->new([$res]);
	$d->Indent(1);
	print $d->Dump;
}

if ( $cmd eq 'predict' ) {
	my $csv = shift or die "I need CSV data.";
	print "RESULT: ", $api->predict($csv);
}
