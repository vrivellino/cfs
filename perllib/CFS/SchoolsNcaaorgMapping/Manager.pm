package CFS::SchoolsNcaaorgMapping::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::SchoolsNcaaorgMapping;

sub object_class { 'CFS::SchoolsNcaaorgMapping' }

__PACKAGE__->make_manager_methods('schools_ncaaorg_mappings');

1;

