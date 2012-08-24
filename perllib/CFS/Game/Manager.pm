package CFS::Game::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::Game;

sub object_class { 'CFS::Game' }

__PACKAGE__->make_manager_methods('games');

1;

