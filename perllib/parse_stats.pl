#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::School;
require CFS::SchoolNameOverride;
require CFS::Stat;
require CFS::ConferenceCode;

my $cfsdb = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die;

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
			if ( $content =~ m/Conference:[<]\/strong[>] [<]a href="\/cfb\/conferences\/[^"]+"[>]([^<]+)[<]\/a[>]/o ) {
				$conf = $1;
			}

			# extract W-L record
			if ( $content =~ m/Record:[<]\/strong[>] (\d+)-(\d+)(-\d+)?,/o ) {
				$wins = $1;
				$losses = $2;
				$ties = $3 || 0;
				$ties =~ s/^-//o;
				$games = $wins + $losses + $ties;
			}

			# extract points scored per game
			if ( $content =~ m/[>]PTS\/G:[<]\/strong[>] ([\d.]+) /o ) {
				$ppg = $1;
			}

			# extract points allowed per game
			if ( $content =~ m/[>]Opp PTS\/G:[<]\/strong[>] ([\d.]+) /o ) {
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
				if ( $content =~ m/[<]td align="right" [>]([\d.]+)[<]\/td[>]/o ) {
					if ( $is_offense ) {
						$o_pass_yds = $1;
					} else {
						$d_pass_yds = $1;
					}
				}
				$content = <HTML>; #Passing Touchdowns
				$content = <HTML>; #Rush Attempts
				$content = <HTML>; #Rushing Yards
				if ( $content =~ m/[<]td align="right" [>]([\d.]+)[<]\/td[>]/o ) {
					if ( $is_offense ) {
						$o_rush_yds = $1;
					} else {
						$d_rush_yds = $1;
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

		# sanity checks
		die "$html_file: Can't determine year!" unless $year;
		die "$html_file: Can't determine conference affiliation!" unless $conf;
		die "$html_file: Can't determine win/loss record!" unless $games;
		die "$html_file: Can't determine PPG!" unless $ppg;
		die "$html_file: Can't determine opponent PPG!" unless $opp_ppg;
		die "$html_file: Can't determine Off passing yds/gm!" unless $o_pass_yds;
		die "$html_file: Can't determine Off rushing yds/gm!" unless $o_rush_yds;
		die "$html_file: Can't determine Off penalty yds/gm!" unless $o_pen_yds;
		die "$html_file: Can't determine Off TO/gm!" unless $o_to;
		die "$html_file: Can't determine Def passing yds/gm!" unless $d_pass_yds;
		die "$html_file: Can't determine Def rushing yds/gm!" unless $d_rush_yds;
		die "$html_file: Can't determine Def penalty yds/gm!" unless $d_pen_yds;
		die "$html_file: Can't determine Def TO/gm!" unless $d_to;

		my $c_code = CFS::ConferenceCode->new( db => $cfsdb, name => $conf );
		die "$html_file: Unknown conference: $conf" unless $c_code->load(speculative => 1);

		my $name_override = CFS::SchoolNameOverride->new( db => $cfsdb, original_name => $team );
		$team = $name_override->name if $name_override->load( speculative => 1 );

		my $stat_record = CFS::Stat->new( db => $cfsdb,
			name => $team,
			season => $year,
			conference => $c_code->name(),
			games => $games,
			win => $wins,
			loss => $losses,
			ppg => $ppg,
			opp_ppg => $opp_ppg,
			o_pass_yds => $o_pass_yds,
			o_rush_yds => $o_rush_yds,
			o_pen_yds => $o_pen_yds,
			o_to => $o_to,
			d_pass_yds => $d_pass_yds,
			d_rush_yds => $d_rush_yds,
			d_pen_yds => $d_pen_yds,
			d_to => $d_to
		);

		$stat_record->save();
	}
}
