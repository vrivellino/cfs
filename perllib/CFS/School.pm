package CFS::School;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'schools',

  columns => [
    name        => { type => 'varchar', length => 31, not_null => 1 },
    yr_from     => { type => 'scalar', default => 1901, length => 4, not_null => 1 },
    yr_to       => { type => 'scalar', default => 2012, length => 4, not_null => 1 },
    yrs         => { type => 'integer', default => '0', not_null => 1 },
    games       => { type => 'integer', default => '0', not_null => 1 },
    win         => { type => 'integer', default => '0', not_null => 1 },
    loss        => { type => 'integer', default => '0', not_null => 1 },
    tie         => { type => 'integer', default => '0', not_null => 1 },
    pct         => { type => 'numeric', default => '0.000', not_null => 1, precision => 4, scale => 3 },
    bowls       => { type => 'integer', default => '0', not_null => 1 },
    bowl_win    => { type => 'integer', default => '0', not_null => 1 },
    bowl_loss   => { type => 'integer', default => '0', not_null => 1 },
    bowl_tie    => { type => 'integer', default => '0', not_null => 1 },
    bowl_pct    => { type => 'numeric', default => '0.000', not_null => 1, precision => 4, scale => 3 },
    sr_srs      => { type => 'numeric', default => '0.00', not_null => 1, precision => 4, scale => 2 },
    sr_sos      => { type => 'numeric', default => '0.00', not_null => 1, precision => 4, scale => 2 },
    ap_yrs      => { type => 'integer', default => '0', not_null => 1 },
    conf_champs => { type => 'integer', default => '0', not_null => 1 },
    notes       => { type => 'varchar', default => '', length => 63, not_null => 1 },
  ],

  primary_key_columns => [ 'name' ],

  relationships => [
    stats => {
      class      => 'CFS::Stat',
      column_map => { name => 'name' },
      type       => 'one to many',
    },

    t1s => {
      map_class => 'CFS::PastGame',
      map_from  => 't2',
      map_to    => 't1',
      type      => 'many to many',
    },

    t2s => {
      map_class => 'CFS::PastGame',
      map_from  => 't1',
      map_to    => 't2',
      type      => 'many to many',
    },
  ],
);

1;

