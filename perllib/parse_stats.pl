#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::School;
require CFS::SchoolNameOverride;
require CFS::Stat;
require CFS::ConferenceCode;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

die "I need a stats directory!" unless $ARGV[0];

while ( my $dir = shift ) {
	opendir STATDIR, $dir or die "Can't opendir() $dir: $!";
	my @html_files = grep { /[.]html$/ && -f "$dir/$_" } readdir STATDIR;
	close STATDIR;

	foreach my $html_file ( @html_files) {

		my $team = $html_file;
		$team =~ s/[.]html$//o;

		open HTML, "$dir/$html_file" or die "Can't open() '$dir/$html_file'";

		my $year;
		my $conf;
		my ($ppg, $opp_ppg);
		my ($wins, $losses, $ties, $games);

		my ($o_pass_yds, $o_rush_yds, $o_pen_yds, $o_to);
		my ($d_pass_yds, $d_rush_yds, $d_pen_yds, $d_to);

		while ( my $content = <HTML> ) {
			chomp $content;

			# figure out what season this is for
			if ( $content =~ m/[<]title[>](\d\d\d\d) /o ) {
				$year = $1;
			}

			# extract conference affiliation
			if ( $content =~ m/Conference:[<]\/span[>] [<]a href="\/cfb\/conferences\/[^"]+"[>]([^<]+)[<]\/a[>]/o ) {
				$conf = $1;
			}

			# extract W-L record
			if ( $content =~ m/Record:[<]\/span[>] (\d+)-(\d+)(-\d+)?,/o ) {
				$wins = $1;
				$losses = $2;
				$ties = $3 || 0;
				$ties =~ s/^-//o;
				$games = $wins + $losses + $ties;
			}

			# extract points scored per game
			if ( $content =~ m/[>]PS\/G:[<]\/span[>] ([\d.]+) /o ) {
				$ppg = $1;
			}

			# extract points allowed per game
			if ( $content =~ m/[>]PA\/G:[<]\/span[>] ([\d.]+) /o ) {
				$opp_ppg = $1;
			}

			my $is_offense = 0;
			if ( $content =~ m/[<]td align="left" [>](Offense|Defense)[<]\/td[>]/o ) {
				$is_offense = 1 if $1 eq 'Offense';
				$content = <HTML>; #Games
				$content = <HTML>; #Pass Completions
				$content = <HTML>; #Pass Attempts
				$content = <HTML>; #Pass Completion Perecentage
				$content = <HTML>; #Passing Yards
				if ( $content =~ m/[<]td align="right" [>](-)?([\d.]+)[<]\/td[>]/o ) {
					if ( $is_offense ) {
						$o_pass_yds = $2;
						$o_pass_yds = 0 if $1;
					} else {
						$d_pass_yds = $2;
						$d_pass_yds = 0 if $1;
					}
				}
				$content = <HTML>; #Passing Touchdowns
				$content = <HTML>; #Rush Attempts
				$content = <HTML>; #Rushing Yards
				if ( $content =~ m/[<]td align="right" [>](-)?([\d.]+)[<]\/td[>]/o ) {
					if ( $is_offense ) {
						$o_rush_yds = $2;
						$o_rush_yds = 0 if $1;
					} else {
						$d_rush_yds = $2;
						$d_rush_yds = 0 if $1;
					}
				}
				$content = <HTML>; #Rushing Yards Per Attempt
				$content = <HTML>; #Rushing Touchdowns
				$content = <HTML>; #Plays (Pass Attempts plus Rush Attempts)
				$content = <HTML>; #Total Yards (Pass Yards plus Rushing Yards )
				$content = <HTML>; #Total Yards Per Play
				$content = <HTML>; #First Downs by Pass
				$content = <HTML>; #First Downs by Rush
				$content = <HTML>; #First Downs by Penalty
				$content = <HTML>; #First Downs
				$content = <HTML>; #Penalties
				$content = <HTML>; #Penalty Yards
				if ( $content =~ m/[<]td align="right" [>]([\d.]+)[<]\/td[>]/o ) {
					if ( $is_offense ) {
						$o_pen_yds = $1;
					} else {
						$d_pen_yds = $1;
					}
				}
				$content = <HTML>; #Fumbles Lost
				$content = <HTML>; #Passing Interceptions
				$content = <HTML>; #Turnovers
				if ( $content =~ m/[<]td align="right" [>]([\d.]+)[<]\/td[>]/o ) {
					if ( $is_offense ) {
						$o_to = $1;
					} else {
						$d_to = $1;
					}
				}
			}
		}

		close HTML;

		my $warnmsg = '';

		# sanity checks
		$warnmsg = "$html_file: Can't determine year!" unless $year;
		$warnmsg = "$html_file: Can't determine conference affiliation!" unless $conf;
		$warnmsg = "$html_file: Can't determine win/loss record!" unless $games;
		$warnmsg = "$html_file: Can't determine PPG!" unless defined $ppg;
		$warnmsg = "$html_file: Can't determine opponent PPG!" unless defined $opp_ppg;
		$warnmsg = "$html_file: Can't determine Off passing yds/gm!" unless defined $o_pass_yds;
		$warnmsg = "$html_file: Can't determine Off rushing yds/gm!" unless defined $o_rush_yds;
		$warnmsg = "$html_file: Can't determine Off penalty yds/gm!" unless defined $o_pen_yds;
		$warnmsg = "$html_file: Can't determine Off TO/gm!" unless defined $o_to;
		$warnmsg = "$html_file: Can't determine Def passing yds/gm!" unless defined $d_pass_yds;
		$warnmsg = "$html_file: Can't determine Def rushing yds/gm!" unless defined $d_rush_yds;
		$warnmsg = "$html_file: Can't determine Def penalty yds/gm!" unless defined $d_pen_yds;
		$warnmsg = "$html_file: Can't determine Def TO/gm!" unless defined $d_to;

		if ( $warnmsg ) {
			warn $warnmsg;
			next;
		}

		my $c_code = CFS::ConferenceCode->new( db => $cfsdb, name => $conf );
		die "$html_file: Unknown conference: $conf" unless $c_code->load(speculative => 1);

		my $name_override = CFS::SchoolNameOverride->new( db => $cfsdb, original_name => $team );
		$team = $name_override->name if $name_override->load( speculative => 1 );


		my $stat_record = CFS::Stat->new( db => $cfsdb, name => $team, season => $year );
		# load it, if it's there
		$stat_record->load( speculative => 1 );

		# re-write stats
		$stat_record->conference($c_code->name());
		$stat_record->games($games);
		$stat_record->win($wins);
		$stat_record->loss($losses);
		$stat_record->ppg($ppg);
		$stat_record->opp_ppg($opp_ppg);
		$stat_record->o_pass_yds($o_pass_yds);
		$stat_record->o_rush_yds($o_rush_yds);
		$stat_record->o_pen_yds($o_pen_yds);
		$stat_record->o_to($o_to);
		$stat_record->d_pass_yds($d_pass_yds);
		$stat_record->d_rush_yds($d_rush_yds);
		$stat_record->d_pen_yds($d_pen_yds);
		$stat_record->d_to($d_to);

		$stat_record->save();
	}
}
