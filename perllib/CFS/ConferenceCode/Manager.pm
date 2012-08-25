package CFS::ConferenceCode::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::ConferenceCode;

sub object_class { 'CFS::ConferenceCode' }

__PACKAGE__->make_manager_methods('conference_codes');

1;

