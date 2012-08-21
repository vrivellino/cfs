package CFS::GoogleOauthToken;

use strict;

use base qw(CFS::DB::Object::AutoBase1);

__PACKAGE__->meta->setup(
  table   => 'google_oauth_tokens',

  columns => [
    id      => { type => 'varchar', length => 32, not_null => 1 },
    token   => { type => 'varchar', default => '', length => 64, not_null => 1 },
    expires => { type => 'integer', default => '0', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],

  unique_key => [ 'token' ],
);

1;

