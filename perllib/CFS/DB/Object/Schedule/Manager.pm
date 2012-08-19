package CFS::DB::Object::Schedule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::DB::Object::Schedule;

sub object_class { 'CFS::DB::Object::Schedule' }

__PACKAGE__->make_manager_methods('schedules');

1;

