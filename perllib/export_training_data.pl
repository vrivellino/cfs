#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::VTrainingData;
use CFS::VTrainingData::Manager;

my $cfsdb = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die;

die "I need season(s) to export!" unless $ARGV[0];

foreach my $yr ( @ARGV ) {

	die "$yr is not a valid season!" unless $yr =~ m/^\d\d\d\d$/o;
	
	open CSV, '>', "training_data-$yr.csv" or die "Failed to open training_data-$yr.csv: $!";
	my $training_data_i = CFS::VTrainingData::Manager->get_v_training_data_iterator(db=>$cfsdb, query => [ season => $yr ]);

	while ( my $row = $training_data_i->next ) {

		# non-numeric features
		my $site = $row->t_site();
		$site =~ s/^\s*/"/o;
		$site =~ s/\s*$/"/o;
		my $t1_conf = $row->t_t1_conf();
		$t1_conf =~ s/^\s*/"/o;
		$t1_conf =~ s/\s*$/"/o;
		my $t2_conf = $row->t_t2_conf();
		$t2_conf =~ s/^\s*/"/o;
		$t2_conf =~ s/\s*$/"/o;

		print CSV
			$row->t_score_diff(), ',',
			$site, ',',
			$row->t_o_score_sum(), ',',
			$row->t_o_score_diff(), ',',
			$row->t_d_score_sum(), ',',
			$row->t_d_score_diff(), ',',
			$row->t_o_rush_sum(), ',',
			$row->t_o_rush_diff(), ',',
			$row->t_d_rush_sum(), ',',
			$row->t_d_rush_diff(), ',',
			$row->t_o_pass_sum(), ',',
			$row->t_o_pass_diff(), ',',
			$row->t_d_pass_sum(), ',',
			$row->t_d_pass_diff(), ',',
			$row->t_pen_diff(), ',',
			$row->t_to_diff(), ',',
			$row->t_rest_diff(), ',',
			$row->t_winpct_diff(), ',',
			$t1_conf, ',',
			$t2_conf, "\n";
	}
	close CSV;
}
