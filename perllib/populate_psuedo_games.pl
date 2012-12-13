#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::Stat;
require CFS::Stat::Manager;
require CFS::SimGame;
require CFS::PastGame::Manager;

require CFS::GoogleAPI;

use Data::Dumper;

sub dump_response {
	my $d = Data::Dumper->new([@_]);
	$d->Indent(1);
	print $d->Dump;
}

my $SEASON = '2012';
my $WEEK = 13;
my $MODEL = 'CFS20042011v2';

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

my $teams = CFS::Stat::Manager->get_objects(db => $cfsdb, query => [ season => $SEASON ]);

foreach my $t1 ( @$teams ) {
	foreach my $t2 ( @$teams ) {
		next if $t1->name eq $t2->name;

		my $p_gm = CFS::SimGame->new(db => $cfsdb,
			season => $SEASON, week => $WEEK, model => $MODEL,
			t1_name => $t1->name, t2_name => $t2->name,
			site => 'T1' );

		my $past_gm = CFS::PastGame::Manager->get_objects(db => $cfsdb,
			query => [ season => $SEASON, site => 'T1', t1_name => $t1->name, t2_name => $t2->name ],
			sort_by => 'gm_date DESC'
		);

		if ( $past_gm->[0] ) {
			$p_gm->prediction(0);
			if ( $past_gm->[0]->t1_score > $past_gm->[0]->t2_score ) {
				$p_gm->prediction(100);
			} elsif ( $past_gm->[0]->t1_score < $past_gm->[0]->t2_score ) {
				$p_gm->prediction(-100);
			}
		}

		$p_gm->save;
	}
}

