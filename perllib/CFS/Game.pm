package CFS::Game;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'games',

  columns => [
    season          => { type => 'scalar', default => '0000', length => 4, not_null => 1 },
    week            => { type => 'integer', default => '0', not_null => 1 },
    model           => { type => 'varchar', default => '', length => 64, not_null => 1 },
    prediction      => { type => 'integer' },
    prediction_lock => { type => 'character', length => 36 },
    gm_date         => { type => 'date', not_null => 1 },
    gm_day          => { type => 'enum', check_in => [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ], default => 'Sat', not_null => 1 },
    t1_name         => { type => 'varchar', length => 32, not_null => 1 },
    t1_score        => { type => 'integer' },
    t1_last         => { type => 'date', default => '0000-00-00', not_null => 1 },
    site            => { type => 'enum', check_in => [ 'T1', 'N', 'B' ], default => 'T1' },
    t2_name         => { type => 'varchar', length => 32, not_null => 1 },
    t2_score        => { type => 'integer' },
    t2_last         => { type => 'date', default => '0000-00-00', not_null => 1 },
    line            => { type => 'numeric', precision => 3, scale => 1 },
    notes           => { type => 'varchar', default => '', length => 63, not_null => 1 },
  ],

  primary_key_columns => [ 'gm_date', 't1_name', 't2_name' ],

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

