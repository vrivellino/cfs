#!/usr/bin/perl

use strict;
use warnings;

use CFS::GoogleAPI;
use Data::Dumper;

my $cmd = lc shift || 'list';

my $api = CFS::GoogleAPI->new() or die "Something bad happened";

if ( $cmd eq 'list' ) {
	$api->print_model_list();
	exit;
}

if ( $cmd eq 'get' ) {
	my $id = shift or die "You need to specify a model ID";
	$api->model_id($id) or die "Invalid model id: $id";
	my $res = $api->google_prediction_request('get');
	dump_response($res);
	exit;
}

if ( $cmd eq 'analyze' ) {
	my $id = shift or die "You need to specify a model ID";
	$api->model_id($id) or die "Invalid model id: $id";
	my $res = $api->google_prediction_request('analyze');
	dump_response($res);
	exit;
}

if ( $cmd eq 'predict' ) {
	my $id = shift or die "You need to specify a model ID";
	$api->model_id($id) or die "Invalid model id: $id";
	my $csv = shift or die "I need CSV data.";
	print "RESULT: ", $api->predict($csv), "\n";
	exit;
}

if ( $cmd eq 'insert' ) {
	my $id = shift or die "You need to specify a model ID";
	my $csv_loc = shift or die "You need to specify a csv location.";
	my $res = $api->train_model($id, $csv_loc);
	dump_response($res);
	exit;
}

if ( $cmd eq 'delete' ) {
	my $id = shift or die "You need to specify a model ID";
	$api->model_id($id) or die "Invalid model id: $id";
	my $res = $api->delete_model();

	exit;
}

die "Unknown option specified.";


sub dump_response {
	my $d = Data::Dumper->new([@_]);
	$d->Indent(1);
	print $d->Dump;
}
