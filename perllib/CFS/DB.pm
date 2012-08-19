package CFS::DB;

use base qw(Rose::DB);

__PACKAGE__->use_private_registry;

# read-only (default)
__PACKAGE__->register_db(
 	domain   => 'default',
 	type     => 'default',
	driver   => 'mysql',
	database => 'cfs',
	host     => 'localhost',
	#mysql_socket => '/var/lib/mysql/mysql.sock',
	username => 'root'
	#password => '',
);

## read-write
#__PACKAGE__->register_db(
# 	domain   => 'default',
#	type     => 'rw',
#	driver   => 'mysql',
#	database => 'cfs',
#	host     => 'localhost',
#	username => 'root',
#	#password => '',
#);

1;
