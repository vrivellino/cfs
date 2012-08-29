package CFS::VGameResult;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'v_game_results',

  columns => [
    season            => { type => 'scalar', default => '0000', length => 4, not_null => 1 },
    model             => { type => 'varchar', default => '', length => 64, not_null => 1 },
    gm_date           => { type => 'date', default => '0000-00-00', not_null => 1 },
    game_type         => { type => 'varchar', default => '', length => 10, not_null => 1 },
    game              => { type => 'varchar', length => 78 },
    abs_pred          => { type => 'numeric', precision => 4, scale => 1 },
    game_result       => { type => 'varchar', length => 7 },
    prediction_result => { type => 'varchar', length => 9 },
    notes             => { type => 'varchar', default => '', length => 63, not_null => 1 },
  ],

  primary_key_columns => [ 'prediction_result' ],
);

1;

