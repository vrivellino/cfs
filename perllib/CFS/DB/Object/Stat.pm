package CFS::DB::Object::Stat;

use strict;

use base qw(CFS::DB::Object::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'stats',

  columns => [
    name       => { type => 'character', length => 31, not_null => 1 },
    season     => { type => 'scalar', length => 4, not_null => 1 },
    conference => { type => 'character', default => '', length => 10, not_null => 1 },
    games      => { type => 'integer', default => '0', not_null => 1 },
    win        => { type => 'integer', default => '0', not_null => 1 },
    loss       => { type => 'integer', default => '0', not_null => 1 },
    ppg        => { type => 'numeric', default => '0.0', not_null => 1, precision => 4, scale => 1 },
    opp_ppg    => { type => 'numeric', default => '0.0', not_null => 1, precision => 4, scale => 1 },
    o_pass_yds => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    o_rush_yds => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    o_pen_yds  => { type => 'numeric', default => '0.0', not_null => 1, precision => 4, scale => 1 },
    o_to       => { type => 'numeric', default => '0.0', not_null => 1, precision => 3, scale => 1 },
    d_pass_yds => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    d_rush_yds => { type => 'numeric', default => '0.0', not_null => 1, precision => 5, scale => 1 },
    d_pen_yds  => { type => 'numeric', default => '0.0', not_null => 1, precision => 4, scale => 1 },
    d_to       => { type => 'numeric', default => '0.0', not_null => 1, precision => 3, scale => 1 },
  ],

  primary_key_columns => [ 'name', 'season' ],

  foreign_keys => [
    school => {
      class       => 'CFS::DB::Object::School',
      key_columns => { name => 'name' },
    },
  ],
);

1;

