package CFS::SimGame;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'sim_games',

  columns => [
    season          => { type => 'scalar', length => 4, not_null => 1 },
    week            => { type => 'integer', not_null => 1 },
    model           => { type => 'varchar', default => '', length => 64, not_null => 1 },
    prediction      => { type => 'numeric', precision => 4, scale => 1 },
    prediction_lock => { type => 'character', length => 36 },
    t1_name         => { type => 'varchar', length => 32, not_null => 1 },
    t1_last         => { type => 'date', default => '0000-00-00', not_null => 1 },
    site            => { type => 'enum', check_in => [ 'T1', 'N', 'B' ], default => 'T1' },
    t2_name         => { type => 'varchar', length => 32, not_null => 1 },
    t2_last         => { type => 'date', default => '0000-00-00', not_null => 1 },
  ],

  primary_key_columns => [ 'season', 'week', 't1_name', 't2_name' ],

  foreign_keys => [
    t1 => {
      class       => 'CFS::School',
      key_columns => { t1_name => 'name' },
    },

    t2 => {
      class       => 'CFS::School',
      key_columns => { t2_name => 'name' },
    },
  ],
);

1;

