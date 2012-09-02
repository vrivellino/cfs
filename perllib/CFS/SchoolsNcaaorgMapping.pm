package CFS::SchoolsNcaaorgMapping;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'schools_ncaaorg_mappings',

  columns => [
    ncaaorg_name => { type => 'varchar', length => 31, not_null => 1 },
    name         => { type => 'varchar', default => '', length => 31, not_null => 1 },
  ],

  primary_key_columns => [ 'ncaaorg_name' ],

  unique_key => [ 'name' ],
);

1;

