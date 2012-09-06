#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::VTrainingData;
require CFS::VTrainingData::Manager;

my $cfsdb = CFS::DB->new(default_connect_options=>{AutoCommit=>1,RaiseError=>1,PrintError=>1}) or die;

die "I need season(s) to export!" unless $ARGV[0];

foreach my $yr ( @ARGV ) {

	die "$yr is not a valid season!" unless $yr =~ m/^\d\d\d\d$/o;
	
	my $training_data_i = CFS::VTrainingData::Manager->get_v_training_data_iterator(db=>$cfsdb, query => [ season => $yr ]);

	while ( my $row = $training_data_i->next ) {

		# non-numeric features
		my $site = $row->f_site();
		$site =~ s/^\s*/"/o;
		$site =~ s/\s*$/"/o;
		my $t1_conf = $row->f_t1_conf();
		$t1_conf =~ s/^\s*/"/o;
		$t1_conf =~ s/\s*$/"/o;
		my $t2_conf = $row->f_t2_conf();
		$t2_conf =~ s/^\s*/"/o;
		$t2_conf =~ s/\s*$/"/o;

		print
			$row->r_score_diff(), ',',
			$site, ',',
			$row->f_o_score_sum(), ',',
			$row->f_o_score_diff(), ',',
			$row->f_d_score_sum(), ',',
			$row->f_d_score_diff(), ',',
			$row->f_o_rush_sum(), ',',
			$row->f_o_rush_diff(), ',',
			$row->f_d_rush_sum(), ',',
			$row->f_d_rush_diff(), ',',
			$row->f_o_pass_sum(), ',',
			$row->f_o_pass_diff(), ',',
			$row->f_d_pass_sum(), ',',
			$row->f_d_pass_diff(), ',',
			$row->f_pen_diff(), ',',
			$row->f_to_diff(), ',',
			$row->f_rest_diff(), ',',
			$row->f_winpct_diff(), ',',
			$t1_conf, ',',
			$t2_conf, "\n";
	}
}
