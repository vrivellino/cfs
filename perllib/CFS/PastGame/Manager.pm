package CFS::PastGame::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::PastGame;

sub object_class { 'CFS::PastGame' }

__PACKAGE__->make_manager_methods('past_games');

1;

