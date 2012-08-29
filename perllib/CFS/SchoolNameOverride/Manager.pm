package CFS::SchoolNameOverride::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::SchoolNameOverride;

sub object_class { 'CFS::SchoolNameOverride' }

__PACKAGE__->make_manager_methods('school_name_overrides');

1;

