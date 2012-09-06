#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::Game::Manager;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my $yr = shift or die "I need a season!";
my $week = shift or die "I need a week!";

die "$yr is not a valid season!" unless $yr =~ m/^\d\d\d\d$/o;
die "$week is not a valid week!" unless $week =~ m/^\d+$/o;

my $games = CFS::Game::Manager->get_objects(db=>$cfsdb,
	query => [ season => $yr, week => $week, t1_score => { ne => undef }, t2_score => { ne => undef } ],
	sort_by => 'gm_date ASC' );

print
	"<table>\n",
	"<thead>\n",
	"<tr><th>Date</th><th>Game</th><th>Line</th><th>Result</th><th>Result ATS</th></tr>\n",
	"</thead>\n",
	"<tbody>\n\n";

my $total = 0;
my $su_count = 0;
my $ats_correct = 0;
my $ats_incorrect = 0;

foreach my $gm ( @$games ) {

	my $date = $gm->gm_date->ymd;
	my $prediction = $gm->prediction;
	next unless defined $prediction;
	my $line = $gm->line;
	my $site = '@';
	$site = 'vs' if $gm->site ne 'T1';
	my $h = $gm->t1_name;
	my $v = $gm->t2_name;
	my $h_score = $gm->t1_score;
	my $v_score = $gm->t2_score;

	# default to INCORRECT
	my $correct = 0;
	my $correct_ats = -1;

	# chech the result SU
	$correct = 1 if ( $prediction > 0 && $h_score > $v_score )||( $prediction < 1 && $v_score > $h_score );

	# PUSH
	$correct_ats = 0 if $prediction == $line || $h_score - $v_score == $line;

	# CORRECT
	$correct_ats = 1 if ( $prediction > $line && $h_score - $v_score > $line )||
	                    ( $prediction < $line && $h_score - $v_score < $line );
		
	print "<tr><td>$date</td><td>";

	my $p = abs $prediction;
	if ( $prediction < 0 && $prediction < $line ) {
		print "<strong><em>$v</em></strong> [$p] $site $h";
	} elsif ( $prediction < 0 && $prediction > $line ) {
		print "<strong>$v</strong> [$p] $site <em>$h</em>";
	} elsif ( $prediction < 0 ) {
		print "<strong>$v</strong> [$p] $site $h";
	} elsif ( $prediction > 0 && $prediction > $line ) {
		print "$v $site <strong><em>$h</em></strong> [$p]";
	} elsif ( $prediction > 0 && $prediction < $line ) {
		print "<em>$v</em> $site <strong>$h</strong> [$p]";
	} elsif ( $prediction > 0 ) {
		print "$v $site <strong>$h</strong> [$p]";
	} else {
		print "$v $site $h";
	}

	$total++;
	if ( $correct ) {
		$su_count++;
		print '</td><td>', - $line, '</td><td>', "<span style=\"color: green\"><strong>$v_score-$h_score</strong></span></td>";
	} else {
		print '</td><td>', - $line, '</td><td>', "<span style=\"color: red\">$v_score-$h_score</span></td>";
	}

	if ( $correct_ats > 0 ) {
		$ats_correct++;
		print '<td><span style="color: green"><strong>Correct</strong></span></td>';
	} elsif ( $correct_ats < 0 ) {
		$ats_incorrect++;
		print '<td><span style="color: red">Incorrect</span></td>';
	} else {
		print '<td>Push</td>';
	}

	print "</tr>\n";
}

print "</tbody></table>\n";

print "\n";

print "$su_count-", $total-$su_count, " straight-up, $ats_correct-$ats_incorrect-", $total-$ats_correct-$ats_incorrect, " against the spread\n";
