package CFS::VGameResult::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::VGameResult;

sub object_class { 'CFS::VGameResult' }

__PACKAGE__->make_manager_methods('v_game_results');

1;

