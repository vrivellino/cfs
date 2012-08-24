package CFS::VPredictionQueue;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'v_prediction_queue',

  columns => [
    season          => { type => 'scalar', default => '0000', length => 4, not_null => 1 },
    gamedate        => { type => 'date', default => '0000-00-00', not_null => 1 },
    team1           => { type => 'varchar', length => 31, not_null => 1 },
    team2           => { type => 'varchar', length => 31, not_null => 1 },
    prediction_lock => { type => 'character', length => 36 },
    p_site          => { type => 'enum', check_in => [ 'T1', 'N', 'B' ], default => 'T1' },
    p_o_score_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    p_o_score_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    p_d_score_sum   => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    p_d_score_diff  => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    p_o_rush_sum    => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_o_rush_diff   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_d_rush_sum    => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_d_rush_diff   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_o_pass_sum    => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_o_pass_diff   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_d_pass_sum    => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_d_pass_diff   => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_pen_diff      => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_to_diff       => { type => 'numeric', default => '0.0', not_null => 1, precision => 6, scale => 1 },
    p_rest_diff     => { type => 'integer' },
    p_winpct_diff   => { type => 'numeric', precision => 4, scale => 3 },
    p_t1_conf       => { type => 'varchar', default => '', length => 10, not_null => 1 },
    p_t2_conf       => { type => 'varchar', length => 10, not_null => 1 },
  ],

  primary_key_columns => [ 'p_t2_conf' ],
);

1;

