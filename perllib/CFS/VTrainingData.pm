package CFS::VTrainingData;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'v_training_data',

  columns => [
    season         => { type => 'scalar', default => '0000', length => 4, not_null => 1 },
    gamedate       => { type => 'date', default => '0000-00-00', not_null => 1 },
    team1          => { type => 'varchar', length => 31, not_null => 1 },
    team2          => { type => 'varchar', length => 31, not_null => 1 },
    t_score_diff   => { type => 'integer' },
    t_site         => { type => 'enum', check_in => [ 'T1', 'N', 'B' ], default => 'T1' },
    t_o_score_sum  => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    t_o_score_diff => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    t_d_score_sum  => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    t_d_score_diff => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    t_o_rush_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_o_rush_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_d_rush_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_d_rush_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_o_pass_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_o_pass_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_d_pass_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_d_pass_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_pen_diff     => { type => 'numeric', not_null => 1, precision => 6, scale => 1 },
    t_to_diff      => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    t_rest_diff    => { type => 'integer' },
    t_winpct_diff  => { type => 'numeric', precision => 4, scale => 3 },
    t_t1_conf      => { type => 'varchar', default => '', length => 10, not_null => 1 },
    t_t2_conf      => { type => 'varchar', default => '', length => 10, not_null => 1 },
  ],

  primary_key_columns => [ 't_pen_diff' ],
);

1;

