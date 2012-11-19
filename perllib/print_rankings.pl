#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::VSimulationRanking::Manager;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my $yr = shift or die "I need a season!";
my $week = shift or die "I need a week!";
my $otype = shift || '';

die "$yr is not a valid season!" unless $yr =~ m/^\d\d\d\d$/o;
die "$week is not a valid week!" unless $week =~ m/^\d+$/o;

my $rankings = CFS::VSimulationRanking::Manager->get_objects(db=>$cfsdb,
	query => [ season => $yr, week => $week ] );


if ( $otype eq 'html' ) {
	print
		"<table>\n",
		"<thead>\n",
		"<tr><th>Rank</th><th>Team</th><th>$yr<br/>W-L</th><th>Simulated<br/>Win Pct</th><th>Weighted<br/>Pct</th></tr>\n",
		"</thead>\n",
		"<tbody>\n\n";

} else {
	printf "%-6s%-32s%-9s %14s  %12s\n", 'Rank', 'Team', "$yr W-L", 'Simulated-Win%', 'Weighted-Pct';
}
my $i = 1;
foreach my $row ( @$rankings ) {
	if ( $otype eq 'html' ) {
		print
			"</tbody>\n",
			"</table>\n\n",
			"<!--more-->\n",
			"<table>\n",
			"<thead>\n",
			"<tr><th>Rank</th><th>Team</th><th>$yr<br/>W-L</th><th>Simulated<br/>Win Pct</th><th>Weighted<br/>Pct</th></tr>\n",
			"</thead>\n",
			"<tbody>\n\n" if $i == 26;

		print '<tr><td>', $i++, '</td><td>', $row->team, '</td><td>', $row->record, '</td><td>', $row->sim_pct, '</td><td>', $row->sim_weighted_pct, "</td></tr>\n";
	} else {
		printf "%-6d%-32s%-9s %14.3f  %12.3f\n", $i++, $row->team, $row->record, $row->sim_pct, $row->sim_weighted_pct;
	}
}

print "</tbody></table>\n" if $otype eq 'html';
