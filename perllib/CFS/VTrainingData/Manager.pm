package CFS::VTrainingData::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::VTrainingData;

sub object_class { 'CFS::VTrainingData' }

__PACKAGE__->make_manager_methods('v_training_data');

1;

