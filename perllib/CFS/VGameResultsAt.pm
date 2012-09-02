package CFS::VGameResultsAt;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'v_game_results_ats',

  columns => [
    season            => { type => 'scalar', default => '0000', length => 4, not_null => 1 },
    model             => { type => 'varchar', default => '', length => 64, not_null => 1 },
    gm_date           => { type => 'date', default => '0000-00-00', not_null => 1 },
    game_type         => { type => 'varchar', default => '', length => 10, not_null => 1 },
    game              => { type => 'varchar', length => 78 },
    line              => { type => 'numeric', precision => 3, scale => 1 },
    line_pred_diff    => { type => 'numeric', precision => 5, scale => 1 },
    game_result       => { type => 'varchar', length => 7 },
    prediction_result => { type => 'varchar', length => 9 },
    notes             => { type => 'varchar', default => '', length => 63, not_null => 1 },
  ],

  primary_key_columns => [ 'line_pred_diff' ],
);

1;

