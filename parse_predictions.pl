#!/usr/bin/perl

use strict;
use warnings;

my $sched   = shift or die "Usage: $0 pseudo_sched.csv predictions_out.csv";
my $outfile = shift or die "Usage: $0 pseudo_sched.csv predictions_out.csv";

open SCHED, $sched   or die "Failed to open $sched: $!";
open PREDS, $outfile or die "Failed to open $outfile: $!";

my @games = <SCHED>;
my @results = <PREDS>;

close SCHED;
close PREDS;

my %teams = ();

die "Fatal: number of lines in $sched and $outfile do not match"
	unless scalar @games == scalar @results;

for ( my $i = 0; $games[$i] && $results[$i]; $i++ ) {
	chomp $games[$i];
	chomp $results[$i];

	my ($gm,$week,$date,$day_of_week,$team1,$t1_pts,$site,$team2,$t2_pts,$notes) = split /,/, $games[$i];
	my @prediction = split /,/, $results[$i];

	unless ( $prediction[0] ) {
		warn "Skipping results: ".$results[$i];
		next;
	}

	$teams{$team1} = { gms => 0, wins => 0 } unless ref $teams{$team1};
	$teams{$team2} = { gms => 0, wins => 0 } unless ref $teams{$team2};
	$teams{$team1}->{'gms'}++;
	$teams{$team2}->{'gms'}++;
	if ( $prediction[0] > 0 ) {
		$teams{$team1}->{'wins'}++;
	} else {
		$teams{$team2}->{'wins'}++;
	}
}

#use Data::Dumper;
#print Dumper(\%teams);

my $i = 1;
foreach my $t ( sort { $teams{$b}->{'wins'}/$teams{$b}->{'gms'} <=> $teams{$a}->{'wins'}/$teams{$a}->{'gms'} } keys %teams ) {
	printf "%4s %-32s %0.4f\n", $i++.')', $t, $teams{$t}->{'wins'} / $teams{$t}->{'gms'};
}
