package CFS::DB::Object::School::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::DB::Object::School;

sub object_class { 'CFS::DB::Object::School' }

__PACKAGE__->make_manager_methods('schools');

1;

