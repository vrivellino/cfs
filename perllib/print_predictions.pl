#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::Game::Manager;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my $yr = shift or die "I need a season!";
my $week = shift or die "I need a week!";
my $print_notes = shift || 'yes';
$print_notes = '' if $print_notes eq '-nonotes';

die "$yr is not a valid season!" unless $yr =~ m/^\d\d\d\d$/o;
die "$week is not a valid week!" unless $week =~ m/^\d+$/o;

my $games = CFS::Game::Manager->get_objects(db=>$cfsdb,
	query => [ season => $yr, week => $week, prediction => { ne => undef } ],
	sort_by => 'gm_date ASC' );

print
	"<table>\n",
	"<thead>\n",
	"<tr><th>Date</th><th>Game</th><th>Line</th>";
print "<th>Notes</th>" if $print_notes;
print
	"</tr>\n",
	"</thead>\n",
	"<tbody>\n\n";

foreach my $gm ( @$games ) {

	my $date = $gm->gm_date->ymd;
	my $prediction = $gm->prediction;

	my $line = $gm->line;
	my $site = '@';
	$site = 'vs' if $gm->site ne 'T1';
	my $h = $gm->t1_name;
	my $v = $gm->t2_name;

	my $notes = $gm->notes || '';

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

	print "</td><td>", - $line, "</td>";
	print "<td>$notes</td>" if $print_notes;
	print "</tr>\n";
}

print "</tbody>\n</table>\n";

