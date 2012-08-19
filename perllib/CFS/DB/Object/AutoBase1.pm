package CFS::DB::Object::AutoBase1;
use strict;
use CFS::DB;
use base qw(Rose::DB::Object);

sub init_db { CFS::DB->new() }

1;
