package CFS::VPredictionQueue::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::VPredictionQueue;

sub object_class { 'CFS::VPredictionQueue' }

__PACKAGE__->make_manager_methods('v_prediction_queue');

1;

