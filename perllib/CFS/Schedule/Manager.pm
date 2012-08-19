package CFS::Schedule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::Schedule;

sub object_class { 'CFS::Schedule' }

__PACKAGE__->make_manager_methods('schedules');

1;

