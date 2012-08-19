package CFS::PastSchedule::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::PastSchedule;

sub object_class { 'CFS::PastSchedule' }

__PACKAGE__->make_manager_methods('past_schedules');

1;

