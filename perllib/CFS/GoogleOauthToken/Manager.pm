package CFS::GoogleOauthToken::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use CFS::GoogleOauthToken;

sub object_class { 'CFS::GoogleOauthToken' }

__PACKAGE__->make_manager_methods('google_oauth_tokens');

1;

