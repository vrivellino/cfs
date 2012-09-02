package CFS::VGameResultsAt::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::VGameResultsAt;

sub object_class { 'CFS::VGameResultsAt' }

__PACKAGE__->make_manager_methods('v_game_results_ats');

1;

