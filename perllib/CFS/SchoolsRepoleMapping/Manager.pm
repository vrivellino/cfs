package CFS::SchoolsRepoleMapping::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::SchoolsRepoleMapping;

sub object_class { 'CFS::SchoolsRepoleMapping' }

__PACKAGE__->make_manager_methods('schools_repole_mappings');

1;

