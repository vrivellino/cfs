package CFS::VSimulationRanking::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::VSimulationRanking;

sub object_class { 'CFS::VSimulationRanking' }

__PACKAGE__->make_manager_methods('v_simulation_rankings');

1;

