package CFS::SchoolsRepoleMapping;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'schools_repole_mappings',

  columns => [
    name        => { type => 'varchar', default => '', length => 31, not_null => 1 },
    repole_name => { type => 'varchar', length => 31, not_null => 1 },
  ],

  primary_key_columns => [ 'repole_name' ],

  foreign_keys => [
    school => {
      class       => 'CFS::School',
      key_columns => { name => 'name' },
    },
  ],
);

1;

