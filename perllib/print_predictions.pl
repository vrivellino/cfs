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
	"<tr><th>Date</th><th>Game (line)</th><th>Bodak's Pick</th>";
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

	print "<tr><td>$date</td>";

	if ( $line > 0 ) {
		print "<td>$v<br />$site $h (-$line)</td>";
	} elsif ( $line < 0 ) {
		print "<td>$v ($line)<br />$site $h</td>";
	} else {
		print "<td>$v <br />$site $h</td>";
	}

	my $p = abs $prediction;

	if ( $prediction > 0 ) {
		print "<td>$h to win by $p<br />";
	} elsif ( $prediction < 0 ) {
		print "<td>$v to win by $p<br />";
	} else {
		print "<td>Unknown<br />";
	}

	if ( $prediction > $line ) {
		print "$h to cover</td>";
	} elsif ( $prediction < $line ) {
		print "$v to cover</td>";
	} else {
		print "Push predicted</td>";
	}

	print "<td>$notes</td>" if $print_notes;
	print "</tr>\n";
}

print "</tbody>\n</table>\n";


__END__



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
	"<tr><th>Date</th><th>Game (line)</th><th>Score</th><th>Bodak's Pick</th></tr>\n",
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
		
	print "<tr><td>$date</td>";

	if ( $line > 0 ) {
		print "<td>$v<br />$site $h (-$line)</td>";
	} elsif ( $line < 0 ) {
		print "<td>$v ($line)<br />$site $h</td>";
	} else {
		print "<td>$v <br />$site $h</td>";
	}

	print "<td>$v_score<br />$h_score</td>";

	my $p = abs $prediction;
	my $color = 'green';
	$color = 'red' unless $correct;

	my $pre = '<span style="color: red"><em>';
	my $post = '</em></span>';
	if ( $correct ) {
		$pre = '<span style="color: green"><strong>';
		$post = '</strong></span>';
	}

	if ( $prediction > 0 ) {
		print "<td>$pre$h to win by $p$post<br />";
	} elsif ( $prediction < 0 ) {
		print "<td>$pre$v to win by $p$post<br />";
	} else {
		print "<td>Unknown<br />";
	}

	$pre = '';
	$post = '';
	if ( $correct_ats < 0 ) {
		$pre = '<span style="color: red"><em>';
		$post = '</em></span>';
	} elsif ( $correct_ats > 0 ) {
		$pre = '<span style="color: green"><strong>';
		$post = '</strong></span>';
	}

	if ( $prediction > $line ) {
		print "$pre$h to cover$post</td>";
	} elsif ( $prediction < $line ) {
		print "$pre$v to cover$post</td>";
	} else {
		print "Push predicted";
	}

	print "</tr>\n";

	$total++;
	$su_count++ if $correct;
	if ( $correct_ats > 0 ) {
		$ats_correct++;
	} elsif ( $correct_ats < 0 ) {
		$ats_incorrect++;
	}
}

print "</tbody></table>\n";

print "\n";

print "$su_count-", $total-$su_count, " straight-up, $ats_correct-$ats_incorrect-", $total-$ats_correct-$ats_incorrect, " against the spread\n";
