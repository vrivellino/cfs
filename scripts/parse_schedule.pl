#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Day_of_Year Decode_Month);
use Data::Dumper;

my $schedule_csv = shift or die "Usage: $0 schedule.csv stats.csv";
my $stats_csv    = shift or die "Usage: $0 schedule.csv stats.csv";


# parse stats
my %stats = ();
open CSV, $stats_csv or die "Can't open $stats_csv: $!";
while ( my $line = <CSV> ) {
	chomp $line;

	my ($team, $conf, $games, $wins, $losses, $ppg, $opp_ppg, $o_pass_yds, $o_rush_yds,
	    $o_pen_yds, $o_to, $d_pass_yds, $d_rush_yds, $d_pen_yds, $d_to) = split /,/, $line;
	$stats{$team} = { conference => $conf, games => $games, wins => $wins, losses => $losses,
	                  ppg => $ppg, opp_ppg => $opp_ppg, o_pass_yds => $o_pass_yds,
	                  o_rush_yds => $o_rush_yds, o_pen_yds => $o_pen_yds, o_to => $o_to,
	                  d_pass_yds => $d_pass_yds, d_rush_yds => $d_rush_yds,
	                  d_pen_yds => $d_pen_yds, d_to => $d_to, last_game => 0 };
}
close CSV;

open DBG, '>', 'debug.out' or die "Can't open debug.out: $!";

# parse schedule
my $n = 0;
open CSV, $schedule_csv or die "Can't open $schedule_csv: $!";
while ( my $line = <CSV> ) {
	chomp $line;
	next if $line eq 'Rk,Wk,Date,Day,Winner/Tie,Pts,,Loser/Tie,Pts,Notes';

	my ($gm,$week,$date,$day_of_week,$team1,$t1_pts,$site,$team2,$t2_pts,$notes) =
		split /,/, $line;

	die "Unable to parse date: $date" unless $date =~ m/^([A-Za-z]{3}) (\d{1,2}) (\d\d\d\d)$/o;
	my $month = $1;
	my $day_of_yr = Day_of_Year($3,Decode_Month($month),$2);


	if ( $site eq '@' ) {
		$site = 'T2';
	} else {
		$site = 'T1';
	}
	$site = 'N' if $notes;

	# strip out rankings
	$team1 =~ s/^[(]\d+[)] //o;
	$team2 =~ s/^[(]\d+[)] //o;

	unless ( ref $stats{$team1} ) {
		warn "No stats for $team1 - skipping $team1 vs $team2";
		next;
	}
	unless ( ref $stats{$team2} ) {
		warn "No stats for $team2 - skipping $team1 vs $team2";
		next;
	}

	my $print_debug = 0;
	$print_debug = 1 if rand(1) < 0.15;
	print DBG "\n------\nSite: $site DoY: $day_of_yr\nT1: $team1\n",
	      Dumper($stats{$team1}), "T2: $team2\n", Dumper($stats{$team2}) if $print_debug;

	my @attributes1 = ();
	my $i = 0;

	unless ( $ENV{PREDICTION_GEN} ) {
		# determine result
		$attributes1[$i] = $t1_pts - $t2_pts;
		if ( $print_debug ) {
			print DBG
				"FINAL_POINT_DIFF: ", $attributes1[$i], "\n",
		}
		$i++;
	}

	# determine month played
	if ( $month eq 'Sep' || $month eq 'Aug' ) {
		$attributes1[$i] = '"S"';
	} elsif ( $month eq 'Oct' ) {
		$attributes1[$i] = '"O"';
	} elsif ( $month eq 'Nov' || $month eq 'Dec' ) {
		$attributes1[$i] = '"N"';
	}
	$attributes1[$i] = '"B"' if $notes =~ m/Bowl|BCS Championship/o;
	$attributes1[$i] = '""' if $ENV{PREDICTION_GEN};
	if ( $print_debug ) {
		print DBG
			"WHEN: ", $attributes1[$i], "\n",
	}
	$i++;

	# site
	$attributes1[$i] = '"N"';
	if ( $site eq 'T1' ) {
		$attributes1[$i] = '"R"';
	} elsif ( $site eq 'T2' ){
		$attributes1[$i] = '"R"';
	} elsif ( $attributes1[$i-1] eq '"B"' ) {
		$attributes1[$i] = '"B"';
	}
	if ( $print_debug ) {
		print DBG
			"SITE: ", $attributes1[$i], "\n",
	}
	$i++;

	# off scoring total
	$attributes1[$i] = int( $stats{$team1}->{'ppg'} + $stats{$team2}->{'opp_ppg'} );
	if ( $print_debug ) {
		print DBG
			"O_SCORE_SUM: ", $attributes1[$i], "\n",
	}
	$i++;

	# off scoring differential
	$attributes1[$i] = int( $stats{$team1}->{'ppg'} - $stats{$team2}->{'opp_ppg'} );
	if ( $print_debug ) {
		print DBG
			"O_SCORE_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# def scoring total
	$attributes1[$i] = int( $stats{$team1}->{'opp_ppg'} + $stats{$team2}->{'ppg'} );
	if ( $print_debug ) {
		print DBG
			"D_SCORE_SUM: ", $attributes1[$i], "\n",
	}
	$i++;

	# def scoring differential
	$attributes1[$i] = int( $stats{$team1}->{'opp_ppg'} - $stats{$team2}->{'ppg'} );
	if ( $print_debug ) {
		print DBG
			"D_SCORE_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# off rushing sum
	$attributes1[$i] = int( $stats{$team1}->{'o_rush_yds'} + $stats{$team2}->{'d_rush_yds'} );
	if ( $print_debug ) {
		print DBG
			"O_RUSH_SUM: ", $attributes1[$i], "\n",
	}
	$i++;

	# off rushing differential
	$attributes1[$i] = int( $stats{$team1}->{'o_rush_yds'} - $stats{$team2}->{'d_rush_yds'} );
	if ( $print_debug ) {
		print DBG
			"O_RUSH_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# def rushing sum
	$attributes1[$i] = int( $stats{$team1}->{'d_rush_yds'} + $stats{$team2}->{'o_rush_yds'} );
	if ( $print_debug ) {
		print DBG
			"D_RUSH_SUM: ", $attributes1[$i], "\n",
	}
	$i++;

	# def rushing differential
	$attributes1[$i] = int( $stats{$team1}->{'d_rush_yds'} - $stats{$team2}->{'o_rush_yds'} );
	if ( $print_debug ) {
		print DBG
			"D_RUSH_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# off passing sum
	$attributes1[$i] = int( $stats{$team1}->{'o_pass_yds'} + $stats{$team2}->{'d_pass_yds'} );
	if ( $print_debug ) {
		print DBG
			"O_PASS_SUM: ", $attributes1[$i], "\n",
	}
	$i++;

	# off passing differential
	$attributes1[$i] = int( $stats{$team1}->{'o_pass_yds'} - $stats{$team2}->{'d_pass_yds'} );
	if ( $print_debug ) {
		print DBG
			"O_PASS_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# def passing sum
	$attributes1[$i] = int( $stats{$team1}->{'d_pass_yds'} + $stats{$team2}->{'o_pass_yds'} );
	if ( $print_debug ) {
		print DBG
			"D_PASS_SUM: ", $attributes1[$i], "\n",
	}

	# def passing differential
	$attributes1[$i] = int( $stats{$team1}->{'d_pass_yds'} - $stats{$team2}->{'o_pass_yds'} );
	if ( $print_debug ) {
		print DBG
			"D_PASS_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# penalty differential
	$attributes1[$i] = int( ($stats{$team1}->{'o_pen_yds'}+$stats{$team1}->{'d_pen_yds'})
	                      - ($stats{$team2}->{'o_pen_yds'}+$stats{$team2}->{'d_pen_yds'}) );
	if ( $print_debug ) {
		print DBG
			"PEN_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# turnover differential
	$attributes1[$i] = sprintf '%0.2f', $stats{$team1}->{'d_to'} - $stats{$team1}->{'o_to'} - $stats{$team2}->{'d_to'} + $stats{$team2}->{'o_to'};
	if ( $print_debug ) {
		print DBG
			"TO_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;
	
	# rest interval
	my $team1_rest = $day_of_yr - $stats{$team1}->{'last_game'};
	$team1_rest = 14 if $team1_rest > 14;
	my $team2_rest = $day_of_yr - $stats{$team2}->{'last_game'};
	$team2_rest = 14 if $team2_rest > 14;
	# rest differential
	$attributes1[$i] = $team1_rest - $team2_rest;
	if ( $print_debug ) {
		print DBG
			"REST_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# win differential
	$attributes1[$i] = sprintf '%0.3f', $stats{$team1}->{'wins'}/$stats{$team1}->{'games'}
	                                  - $stats{$team2}->{'wins'}/$stats{$team2}->{'games'};
	if ( $print_debug ) {
		print DBG
			"WIN_DIFF: ", $attributes1[$i], "\n",
	}
	$i++;

	# conference
	$attributes1[$i] = '"'.$stats{$team1}->{'conference'}.'"';
	$i++;
	$attributes1[$i] = '"'.$stats{$team2}->{'conference'}.'"';

	print join(',',@attributes1), "\n";

	if ( $print_debug ) {
		print DBG
			"DATA: ", join(',',@attributes1), "\n",
	}
}
close CSV;
