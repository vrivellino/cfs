package CFS::VSimulationQueue::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::VSimulationQueue;

sub object_class { 'CFS::VSimulationQueue' }

__PACKAGE__->make_manager_methods('v_simulation_queue');

1;

