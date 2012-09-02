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
    r_score_diff   => { type => 'integer' },
    f_site         => { type => 'enum', check_in => [ 'T1', 'N', 'B' ], default => 'T1' },
    f_o_score_sum  => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    f_o_score_diff => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    f_d_score_sum  => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    f_d_score_diff => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    f_o_rush_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_o_rush_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_d_rush_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_d_rush_diff  => { type => 'numeric', not_null => 1, precision => 6, scale => 1 },
    f_o_pass_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_o_pass_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_d_pass_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_d_pass_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_pen_diff     => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_to_diff      => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    f_rest_diff    => { type => 'integer' },
    f_winpct_diff  => { type => 'numeric', precision => 4, scale => 3 },
    f_t1_conf      => { type => 'character', default => '', length => 2, not_null => 1 },
    f_t2_conf      => { type => 'character', default => '', length => 2, not_null => 1 },
  ],

  primary_key_columns => [ 'f_d_rush_diff' ],
);

1;

