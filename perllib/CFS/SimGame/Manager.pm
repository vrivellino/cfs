package CFS::SimGame::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::SimGame;

sub object_class { 'CFS::SimGame' }

__PACKAGE__->make_manager_methods('sim_games');

1;

