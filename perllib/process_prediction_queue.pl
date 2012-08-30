#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::Game;
require CFS::Game::Manager;
require CFS::VSimulationQueue::Manager;
require CFS::VPredictionQueue::Manager;
require CFS::GoogleAPI;
use POSIX qw(ceil floor);

my $CHUNK = 30;

my $cfsdb = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die;
my $api = CFS::GoogleAPI->new(cfsdb => $cfsdb) or die "Something bad happened";

my $queue = shift or die "First arg should be 'predict' or 'sim'";
die "First arg should be 'predict' or 'sim'" unless $queue eq 'predict' || $queue eq 'sim';
my $sim = 0;
$sim = 1 if $queue eq 'sim';

## TODO fold this into VPredictionQueue::??? class
## lock a set of records
my $aRef = $cfsdb->dbh->selectcol_arrayref('SELECT UUID()');
my $uuid = $aRef->[0] or die "Failed to extract UUID";

my $sth_lock;
my $sth_unlock;
if ( $sim ) {
	$sth_lock = $cfsdb->dbh->prepare('UPDATE sim_games SET prediction_lock=? WHERE prediction_lock IS NULL AND prediction IS NULL LIMIT ?')
		or die "DBI prepare() failed";
	$sth_unlock = $cfsdb->dbh->prepare('UPDATE sim_games SET prediction_lock=NULL WHERE prediction_lock=?')
		or die "DBI prepare() failed";
} else {
	$sth_lock = $cfsdb->dbh->prepare('UPDATE games SET prediction_lock=? WHERE prediction_lock IS NULL AND prediction IS NULL LIMIT ?')
		or die "DBI prepare() failed";
	$sth_unlock = $cfsdb->dbh->prepare('UPDATE games SET prediction_lock=NULL WHERE prediction_lock=?')
		or die "DBI prepare() failed";
}

my $running = 1;
while ( $running  ) {

	my $n = $sth_lock->execute($uuid, $CHUNK)
		or die "DBI execute() failed";

	my $prediction_data;
	if ( $sim ) {
		$prediction_data = CFS::VSimulationQueue::Manager->get_objects(db => $cfsdb, query => [ prediction_lock => $uuid ] );
	} else {
		$prediction_data = CFS::VPredictionQueue::Manager->get_objects(db => $cfsdb, query => [ prediction_lock => $uuid ] );
	}

	$running = 0 unless scalar @$prediction_data;

	foreach my $row ( @$prediction_data ) {

		# load original game record
		my $gm_record;
		if ( $sim ) {
			$gm_record = CFS::SimGame->new(db => $cfsdb,
				season => $row->season, week => $row->week, t1_name => $row->team1, t2_name => $row->team2 );
		} else {
			$gm_record = CFS::Game->new(db => $cfsdb,
				gm_date => $row->gamedate, t1_name => $row->team1, t2_name => $row->team2 );
		}
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
		my $prediction_val = $api->predict(@csv);
		unless ( defined $prediction_val ) {
			$gm_record->prediction_lock(undef);
			$gm_record->save();
			$running = 0;
		}

		my $prediction = $prediction_val;
		if ( $prediction_val > 0 ) {
			my $i = floor($prediction_val);
			my $d = $prediction_val - $i;
			if ( $d >= 0 && $d <= 0.25 ) {
				$prediction = $i;
			} elsif ( $d > 0.25 && $d <= 0.75 ) {
				$prediction = $i + 0.5;
			} else {
				$prediction = $i + 1;
			}
		} elsif ( $prediction_val < 1 ) {
			my $i = ceil($prediction_val);
			my $d = $prediction_val - $i;
			if ( $d <= 0 && $d >= -0.25 ) {
				$prediction = $i;
			} elsif ( $d < -0.25 && $d >= -0.75 ) {
				$prediction = $i - 0.5;
			} else {
				$prediction = $i - 1;
			}
		}

		print "RESULT: $prediction_val -> $prediction\n";
		$gm_record->prediction($prediction);
		$gm_record->prediction_lock(undef);
		$gm_record->save();
	}
	# clean any locked records
	$n = $sth_unlock->execute($uuid)
		or die "DBI execute() failed";
	sleep 2 if $running;
}

