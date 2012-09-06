#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::Stat;
require CFS::Stat::Manager;

my $B = 5;
my $SEASON = 2012;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my $teams_cur = CFS::Stat::Manager->get_objects(db => $cfsdb, query => [ season => $SEASON ]);
my %teams_pre = map { $_->{name} => $_ } 
                @{ CFS::Stat::Manager->get_objects(db => $cfsdb, query => [ season => $SEASON - 1 ]) };

foreach my $stat ( @$teams_cur ) {

	my $stat_pre;
	unless ( $stat_pre = $teams_pre{$stat->name} ) {
		warn "Failed to load last year's stats for: ".$stat->name;
		next;
	}

	my $wk = $stat->games;

	next if $wk >= $B;
	my $wins = ($stat->win*$wk + $stat_pre->win*($B-$wk))/$B;
	my $losses = ($stat->loss*$wk + $stat_pre->loss*($B-$wk))/$B;
	my $games = $wins + $losses;

	my $ppg = ($stat->ppg*$wk + $stat_pre->ppg*($B-$wk))/$B;
	my $opp_ppg = ($stat->opp_ppg*$wk + $stat_pre->opp_ppg*($B-$wk))/$B;

	my $o_pass_yds = ($stat->o_pass_yds*$wk + $stat_pre->o_pass_yds*($B-$wk))/$B;
	my $o_rush_yds = ($stat->o_rush_yds*$wk + $stat_pre->o_rush_yds*($B-$wk))/$B;
	my $o_pen_yds = ($stat->o_pen_yds*$wk + $stat_pre->o_pen_yds*($B-$wk))/$B;
	my $o_to = ($stat->o_to*$wk + $stat_pre->o_to*($B-$wk))/$B;

	my $d_pass_yds = ($stat->d_pass_yds*$wk + $stat_pre->d_pass_yds*($B-$wk))/$B;
	my $d_rush_yds = ($stat->d_rush_yds*$wk + $stat_pre->d_rush_yds*($B-$wk))/$B;
	my $d_pen_yds = ($stat->d_pen_yds*$wk + $stat_pre->d_pen_yds*($B-$wk))/$B;
	my $d_to = ($stat->d_to*$wk + $stat_pre->d_to*($B-$wk))/$B;

	$stat->games($games);
	$stat->win($wins);
	$stat->loss($losses);
	$stat->ppg($ppg);
	$stat->opp_ppg($opp_ppg);
	$stat->o_pass_yds($o_pass_yds);
	$stat->o_rush_yds($o_rush_yds);
	$stat->o_pen_yds($o_pen_yds);
	$stat->o_to($o_to);
	$stat->d_pass_yds($d_pass_yds);
	$stat->d_rush_yds($d_rush_yds);
	$stat->d_pen_yds($d_pen_yds);
	$stat->d_to($d_to);

	$stat->save();
}
