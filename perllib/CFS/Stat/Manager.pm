package CFS::Stat::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::Stat;

sub object_class { 'CFS::Stat' }

__PACKAGE__->make_manager_methods('stats');

1;

