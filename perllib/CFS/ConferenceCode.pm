package CFS::ConferenceCode;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'conference_codes',

  columns => [
    name => { type => 'varchar', length => 12, not_null => 1 },
    code => { type => 'character', default => '', length => 2, not_null => 1 },
  ],

  primary_key_columns => [ 'name' ],

  relationships => [
    stats => {
      class      => 'CFS::Stat',
      column_map => { name => 'conference' },
      type       => 'one to many',
    },
  ],
);

1;

