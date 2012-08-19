package CFS::DB::Object;
use strict;
use CFS::DB;
use base qw(Rose::DB::Object);

sub init_db { CFS::DB->new() }

1;
