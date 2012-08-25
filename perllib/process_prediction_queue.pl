#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::Game;
require CFS::Game::Manager;
require CFS::VPredictionQueue::Manager;
require CFS::GoogleAPI;
use POSIX qw(ceil floor);
use Data::Dumper;

sub dump_response {
	my $d = Data::Dumper->new([@_]);
	$d->Indent(1);
	print $d->Dump;
}

my $cfsdb = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die;
my $api = CFS::GoogleAPI->new(cfsdb => $cfsdb) or die "Something bad happened";

## lock a set of records
my $aRef = $cfsdb->dbh->selectcol_arrayref('SELECT UUID()');
my $uuid = $aRef->[0] or die "Failed to extract UUID";
my $sth = $cfsdb->dbh->prepare('UPDATE games SET prediction_lock=? WHERE prediction_lock IS NULL AND prediction IS NULL LIMIT ?')
	or die "DBI prepare() failed";
my $n = $sth->execute($uuid, 30)
	or die "DBI execute() failed";

# extract training data
my $training_data_i = CFS::VPredictionQueue::Manager->get_v_prediction_queue_iterator(db=>$cfsdb,
	query => [ prediction_lock => $uuid ] );

while ( my $row = $training_data_i->next ) {

	# load original game record
	my $gm_record = CFS::Game->new(db => $cfsdb,
		gm_date => $row->gamedate(), t1_name => $row->team1(), t2_name => $row->team2() )
		or die "Failed to load CFS::Game recrd";
	$gm_record->load() or die "Failed to load game record";

	## non-numeric features - strip leading or trailing space
	my $site = $row->f_site();
	$site =~ s/^\s*//o;
	$site =~ s/\s*$//o;
	my $t1_conf = $row->f_t1_conf();
	$t1_conf =~ s/^\s*//o;
	$t1_conf =~ s/\s*$//o;
	my $t2_conf = $row->f_t2_conf();
	$t2_conf =~ s/^\s*//o;
	$t2_conf =~ s/\s*$//o;

	my @csv = (
		$site,
		$row->f_o_score_sum(),
		$row->f_o_score_diff(),
		$row->f_d_score_sum(),
		$row->f_d_score_diff(),
		$row->f_o_rush_sum(),
		$row->f_o_rush_diff(),
		$row->f_d_rush_sum(),
		$row->f_d_rush_diff(),
		$row->f_o_pass_sum(),
		$row->f_o_pass_diff(),
		$row->f_d_pass_sum(),
		$row->f_d_pass_diff(),
		$row->f_pen_diff(),
		$row->f_to_diff(),
		$row->f_rest_diff(),
		$row->f_winpct_diff(),
		$t1_conf,
		$t2_conf
	);
	$api->model_id($gm_record->model()||'_X_UNKNOWN_X_') or die "Invalid model id: ".$gm_record->model();
	my $prediction = $api->predict(@csv);
	next unless defined $prediction;

	if ( $prediction > 0 ) {
		$prediction = ceil($prediction);
	} elsif ( $prediction < 1 ) {
		$prediction = floor($prediction);
	}

	#print "RESULT: $prediction\n";
	$gm_record->prediction($prediction);
	$gm_record->prediction_lock(undef);

	$gm_record->save();
}


exit;


