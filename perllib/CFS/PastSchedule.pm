package CFS::PastSchedule;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'past_schedules',

  columns => [
    season   => { type => 'scalar', length => 4, not_null => 1 },
    week     => { type => 'integer', not_null => 1 },
    gm_date  => { type => 'date', default => '0000-00-00', not_null => 1 },
    gm_day   => { type => 'enum', check_in => [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ], default => 'Sat', not_null => 1 },
    t1_name  => { type => 'character', length => 32, not_null => 1 },
    t1_score => { type => 'integer' },
    site     => { type => 'enum', check_in => [ '', '@' ], default => '' },
    t2_name  => { type => 'character', length => 32, not_null => 1 },
    t2_score => { type => 'integer' },
    notes    => { type => 'varchar', default => '', length => 63, not_null => 1 },
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

