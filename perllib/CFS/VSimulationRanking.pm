package CFS::VSimulationRanking;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'v_simulation_rankings',

  columns => [
    season           => { type => 'scalar', default => '0000', length => 4, not_null => 1 },
    week             => { type => 'integer', default => '0', not_null => 1 },
    team             => { type => 'varchar', length => 31, not_null => 1 },
    record           => { type => 'varchar', default => '', length => 7, not_null => 1 },
    sim_games        => { type => 'bigint', default => '0', not_null => 1 },
    sim_pct          => { type => 'numeric', precision => 4, scale => 3 },
    sim_weighted_pct => { type => 'numeric', precision => 4, scale => 3 },
  ],

  primary_key_columns => [ 'sim_weighted_pct' ],
);

1;

