#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Decode_Month);

require LWP::UserAgent;
require CFS::DB;
require CFS::Game;
require CFS::School;
require CFS::SchoolNameOverride;
require CFS::SchoolsNcaaorgMapping;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my %fcs_cache = ();
my $fcs_school = 'FCS School';

my %last_games = ();
my $neutral_site_count = 0;


my $lwp = LWP::UserAgent->new();
my $response = $lwp->request(HTTP::Request->new(GET => 'http://web1.ncaa.org/mfb/2012/Internet/schedule/DIVISIONB.csv'));
die 'Failed to fetch DIVISIONB.csv from ncaa.org: '.$response->status_line."\n".($response->content||'')."\n"
	unless $response->is_success;

my @csv = split /[\r\n]+/, $response->content;

# sanity check - make sure we're looking at a schedule.csv
my $hdr_str = '"Institution ID","Institution","Game Date","Opponent ID","Opponent Name","Score For","Score Against","Location"';
die "First line is unexpected - expecting: $hdr_str"
	unless $csv[0] eq $hdr_str;

foreach my $line ( @csv ) {
	chomp $line;
	next if $line eq $hdr_str;

	my $year = '';
	my ($n1, $name_A, $date, $n2, $name_B, $score_A, $score_B, $location) = split /,/, $line
		or die "Failed to split line: $line";


	$date =~ s/^"([^"]+)"$/$1/o;
	if ( $date =~ m/^(\d\d)\/(\d\d)\/(\d\d)$/o ) {
		$year = 2000 + $3;
		$year = $3 - 1 if $1 == 1;
		$date = sprintf '%0.4d-%0.2d-%0.2d', 2000+$3, $1, $2;
	}
	die "Can't determine year: $line" unless $year;

	$name_A =~ s/^"([^"]*)"$/$1/o;
	$name_B =~ s/^"([^"]*)"$/$1/o;
	$score_A =~ s/^"([^"]*)"$/$1/o;
	$score_B =~ s/^"([^"]*)"$/$1/o;

	# make sure we don't have empty fields
	next unless $name_A && $name_B && $score_A =~ m/^\d+$/o && $score_B =~ m/^\d+$/o;

	my $name_override = CFS::SchoolsNcaaorgMapping->new( db => $cfsdb, ncaaorg_name => $name_A );
	$name_A = $name_override->name if $name_override->load( speculative => 1 );
	$name_override = CFS::SchoolsNcaaorgMapping->new( db => $cfsdb, ncaaorg_name => $name_B );
	$name_B = $name_override->name if $name_override->load( speculative => 1 );


	my $gm_record = CFS::Game->new( db => $cfsdb,
		gm_date => $date,
		t1_name => $name_A,
		t2_name => $name_B
	);

	next unless $gm_record->load( speculative => 1 );

	my $t1_score = $gm_record->t1_score;
	my $t2_score = $gm_record->t2_score;

	if ( defined $t1_score && defined $t2_score ) {
		# move on if the scores are the same
		next if $t1_score == $score_A && $t2_score == $score_B;
		# warn if they're different
		warn "Changing score for $date/$name_A/$name_B from $t1_score-$t2_score to $score_A-$score_B";
	}

	$gm_record->t1_score($score_A);
	$gm_record->t2_score($score_B);

	print "$name_A / $name_B: $score_A-$score_B\n";
	$gm_record->save();
}
