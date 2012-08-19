#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Day_of_Year Decode_Month);
use Data::Dumper;

my $stats_csv = shift or die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>";
my $date_str  = shift or die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>";
my $team1     = shift or die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>";
my $site      = shift or die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>";
my $team2     = shift or die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>";
die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>" unless $date_str =~ m/^\d\d\d\d-(\d\d)-\d\d$/o;
my $mon = $1;
die "Usage: $0 stats.csv YYYY-DD-MM <Team1> [v|@] <Team2>" unless $site eq 'v' || $site eq '@';

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

die "Team '$team1' not found" unless ref $stats{$team1};
die "Team '$team2' not found" unless ref $stats{$team2};

print Data::Dumper->Dump( [$stats{$team1}, $stats{$team2}], ["\$stats{'$team1'}", "\$stats{'$team2'}"] );

if ( $site eq '@' ) {
	$site = 'T2';
} else {
	$site = 'T1';
}

my @attributes1 = ();
my $i = 0;

# determine month played
if ( $mon == '09' ) {
	$attributes1[$i] = '"S"';
} elsif ( $mon eq '10' ) {
	$attributes1[$i] = '"O"';
} elsif ( $mon eq '11' || $mon eq '12' ) {
	$attributes1[$i] = '"N"';
}
#$attributes1[$i] = '"B"' if $notes =~ m/Bowl|BCS Championship/o;

# site
$i++;
$attributes1[$i] = '"N"';
if ( $site eq 'T1' ) {
	$attributes1[$i] = '"H"';
} elsif ( $site eq 'T2' ){
	$attributes1[$i] = '"A"';
}

# scoring differential
$i++;
$attributes1[$i] = int( $stats{$team1}->{'ppg'} - $stats{$team2}->{'opp_ppg'} );
$i++;
$attributes1[$i] = int( $stats{$team1}->{'opp_ppg'} - $stats{$team2}->{'ppg'} );

# rushing differential
$i++;
$attributes1[$i] = int( $stats{$team1}->{'o_rush_yds'} - $stats{$team2}->{'d_rush_yds'} );
$i++;
$attributes1[$i] = int( $stats{$team1}->{'d_rush_yds'} - $stats{$team2}->{'o_rush_yds'} );

# passing differential
$i++;
$attributes1[$i] = int( $stats{$team1}->{'o_pass_yds'} - $stats{$team2}->{'d_pass_yds'} );
$i++;
$attributes1[$i] = int( $stats{$team1}->{'d_pass_yds'} - $stats{$team2}->{'o_pass_yds'} );

# penalty differential
$i++;
$attributes1[$i] = int( ($stats{$team1}->{'o_pen_yds'}+$stats{$team1}->{'d_pen_yds'})
                      - ($stats{$team2}->{'o_pen_yds'}+$stats{$team2}->{'d_pen_yds'}) );

# turnover differential
$i++;
$attributes1[$i] = sprintf '%0.1f', ($stats{$team1}->{'d_to'}+$stats{$team1}->{'o_to'})
                                  - ($stats{$team2}->{'d_to'}+$stats{$team2}->{'o_to'});
	
## rest interval
#my $team1_rest = $day_of_yr - $stats{$team1}->{'last_game'};
#$team1_rest = 14 if $team1_rest > 14;
#my $team2_rest = $day_of_yr - $stats{$team2}->{'last_game'};
#$team2_rest = 14 if $team2_rest > 14;
# rest differential
$i++;
#$attributes1[$i] = $team1_rest - $team2_rest;
$attributes1[$i] = 0;

# win differential
$i++;
$attributes1[$i] = sprintf '%0.3f', $stats{$team1}->{'wins'}/$stats{$team1}->{'games'}
                                  - $stats{$team2}->{'wins'}/$stats{$team2}->{'games'};

# conference
$i++;
$attributes1[$i] = '"'.$stats{$team1}->{'conference'}.'"';
$i++;
$attributes1[$i] = '"'.$stats{$team2}->{'conference'}.'"';

my $output = join(',',@attributes1) . "\n";
$output =~ s/"/'/go;
print $output;
