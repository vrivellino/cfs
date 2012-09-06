#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Decode_Month);

require CFS::DB;
require CFS::Game;
require CFS::School;
require CFS::SchoolNameOverride;

my $MODEL = 'CFS20042011v2';

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my %fcs_cache = ();
my $fcs_school = 'FCS School';

my %last_games = ();
my $neutral_site_count = 0;

my $sched_csv = shift or die "I need a schedule.csv!";
my $start_week = shift || 1;
my $end_week = shift || 99;

open CSV, $sched_csv or die "Can't open() $sched_csv: $!";

my $line = <CSV>;
chomp $line;

# sanity check - make sure we're looking at a schedule.csv
my $hdr_str = 'Rk,Wk,Date,Day,Winner/Tie,Pts,,Loser/Tie,Pts,Notes';
die "First line is unexpected - expecting: $hdr_str"
	unless $line eq $hdr_str;

while ( my $line = <CSV> ) {
	chomp $line;
	next if $line eq $hdr_str;

	my $year = '';
	my ($n, $wk, $date, $day, $win, $win_score, $site, $lose, $lose_score, $notes) = split /,/, $line
		or die "Failed to split line: $line";

	die "Can't determine week: $line" unless $wk =~ m/\d+/o;

	next if $wk < $start_week || $wk > $end_week;

	if ( $date =~ m/^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d+) (\d\d\d\d)$/o ) {
		my $m = Decode_Month($1) or die "Failed to parse date: $line";
		$year = $3;
		$year = $3 - 1 if $m == 1;
		$date = sprintf '%0.4d-%0.2d-%0.2d', $3, $m, $2;
	}
	die "Can't determine year: $line" unless $year;

	# strip out rankings
	my $win_rank = 99;
	my $lose_rank = 99;
	if ( $win =~ s/^[(](\d+)[)] //o ) {
		$win_rank = $1;
	}
	$lose =~ s/^[(]\d+[)] //o;
	if ( $lose =~ s/^[(](\d+)[)] //o ) {
		$lose_rank = $1;
	}

	$win = $fcs_school if $fcs_cache{$win};
	$lose = $fcs_school if $fcs_cache{$lose};

	my $name_override = CFS::SchoolNameOverride->new( db => $cfsdb, original_name => $win );
	$win = $name_override->name if $name_override->load( speculative => 1 );
	$name_override = CFS::SchoolNameOverride->new( db => $cfsdb, original_name => $lose );
	$lose = $name_override->name if $name_override->load( speculative => 1 );

	# make sure the teams exist
	my $win_school = CFS::School->new(db => $cfsdb, name => $win );
	my $lose_school = CFS::School->new(db => $cfsdb, name => $lose );
	unless( $win_school->load(speculative => 1) ) {
		warn "$win not found - converting to $fcs_school";
		$fcs_cache{$win} = 1;
		$win = $fcs_school;
		$win_school = CFS::School->new(db => $cfsdb, name => $win );
		$win_school->load(speculative => 1) or die "Failed to load $fcs_school stub record";
	}
	unless( $lose_school->load(speculative => 1) ) {
		warn "$lose not found - converting to $fcs_school";
		$fcs_cache{$lose} = 1;
		$lose = $fcs_school;
		$lose_school = CFS::School->new(db => $cfsdb, name => $lose );
		$lose_school->load(speculative => 1) or die "Failed to load $fcs_school stub record";
	}
	die "Both teams are FCS Schools?!? Something wonky." if $win eq $fcs_school && $lose eq $fcs_school;

	if ( $notes =~ m/Bowl|BCS Championship/o ) {
		$site = 'B';
	} elsif ( $notes ) {
		$site = 'N';
	} elsif ( $site eq '@' ) {
		$site = 'T2';
	} elsif ($ site eq '' ) {
		$site = 'T1';
	} else {
		die "Can't determine site: $line";
	}

	my $gm_record = CFS::Game->new( db => $cfsdb,
		season => $year,
		model => $MODEL,
		week => $wk,
		gm_date => $date,
		gm_day => $day,
		t1_name => $win_school->name(),
		t1_last => $last_games{$win_school->name()} || '0000-00-00',
		t2_name => $lose_school->name(),
		t2_last => $last_games{$lose_school->name()} || '0000-00-00',
		notes => $notes
	);
	$gm_record->t1_score($win_score) if $win_score =~ m/^\d+$/o;
	$gm_record->t2_score($lose_score) if $lose_score =~ m/^\d+$/o;

	my $flip_teams = 0;

	if ( $site eq 'T2' ) {
		# if site is T2, it's regular season, so flip
		$gm_record->site('T1');
		$flip_teams = 1;
	} elsif ( $site eq 'B' || $site eq 'N' ) {
		$gm_record->site($site);
		## if site is bowl or neutral, make higher ranked team home team
		#$flip_teams = 1 if $lose_rank < $win_rank;
		# alternate flipping of neutral/bowl games
		$flip_teams = 1 if $neutral_site_count++ % 2;
	} else {
		$gm_record->site('T1');
	}

	if ( $flip_teams ) {
		$gm_record->t1_name( $lose_school->name() );
		$gm_record->t1_score($lose_score) if $lose_score =~ m/^\d+$/o;
		$gm_record->t1_last( $last_games{$lose_school->name()}||'0000-00-00' );
		$gm_record->t2_name( $win_school->name() );
		$gm_record->t2_score($win_score) if $win_score =~ m/^\d+$/o;
		$gm_record->t2_last( $last_games{$win_school->name()}||'0000-00-00' );
	}

	$gm_record->save();

	$last_games{$win_school->name()} = $date unless $win_school->name() eq $fcs_school;
	$last_games{$lose_school->name()} = $date unless $lose_school->name() eq $fcs_school;
}
close CSV;
