package CFS::DB::Object::Stat::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::DB::Object::Stat;

sub object_class { 'CFS::DB::Object::Stat' }

__PACKAGE__->make_manager_methods('stats');

1;

