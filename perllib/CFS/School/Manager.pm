package CFS::School::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::School;

sub object_class { 'CFS::School' }

__PACKAGE__->make_manager_methods('schools');

1;

