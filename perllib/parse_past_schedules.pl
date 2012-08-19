#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Decode_Month);

require CFS::DB;
require CFS::PastGame;
require CFS::School;

my $cfsdb = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die;

my %fcs_cache = ();
my $fcs_school = 'FCS School';

die "I need a schedules.csv!" unless $ARGV[0];

while ( my $sched_csv = shift ) {
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
		my ($n, $wk, $date, $day, $t1, $t1_score, $site, $t2, $t2_score, $notes) = split /,/, $line
			or die "Failed to split line: $line";

		if ( $date =~ m/^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d+) (\d\d\d\d)$/o ) {
			my $m = Decode_Month($1) or die "Failed to parse date: $line";
			$year = $3;
			$year = $3 - 1 if $m == 1;
			$date = sprintf '%0.4d-%0.2d-%0.2d', $3, $m, $2;
		}

		# strip out rankings
		$t1 =~ s/^[(]\d+[)] //o;
		$t2 =~ s/^[(]\d+[)] //o;

		$t1 = $fcs_school if $fcs_cache{$t1};
		$t2 = $fcs_school if $fcs_cache{$t2};

		# make sure the teams exist
		my $school1 = CFS::School->new(db => $cfsdb, name => $t1 );
		my $school2 = CFS::School->new(db => $cfsdb, name => $t2 );
		unless( $school1->load(speculative => 1) ) {
			warn "$t1 not found - converting to $fcs_school";
			$fcs_cache{$t1} = 1;
			$t1 = $fcs_school;
			$school1 = CFS::School->new(db => $cfsdb, name => $t1 );
			$school1->load(speculative => 1) or die "Failed to load $fcs_school stub record";
		}
		unless( $school2->load(speculative => 1) ) {
			warn "$t2 not found - converting to $fcs_school";
			$fcs_cache{$t2} = 1;
			$t2 = $fcs_school;
			$school2 = CFS::School->new(db => $cfsdb, name => $t2 );
			$school2->load(speculative => 1) or die "Failed to load $fcs_school stub record";
		}
		die "Both teams are FCS Schools?!? Something wonky." if $t1 eq $fcs_school && $t2 eq $fcs_school;

		# make sure the schools exist

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

		# basic sanity checks
		die "Can't determine year: $line" unless $year;
		die "Can't determine week: $line" unless $wk =~ m/\d+/o;

		my $gm_record = CFS::PastGame->new( db => $cfsdb,
		season => $year,
		week => $wk,
		gm_date => $date,
		gm_day => $day,
		t1_name => $school1->name(),
		t1_score => $t1_score,
		site => $site,
		t2_name => $school2->name(),
		t2_score => $t2_score,
		notes => $notes
		);

		$gm_record->save();
	}
	close CSV;
}
