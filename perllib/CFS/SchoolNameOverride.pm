package CFS::SchoolNameOverride;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'school_name_overrides',

  columns => [
    original_name => { type => 'varchar', length => 31, not_null => 1 },
    name          => { type => 'varchar', default => '', length => 31, not_null => 1 },
  ],

  primary_key_columns => [ 'original_name' ],
);

1;

