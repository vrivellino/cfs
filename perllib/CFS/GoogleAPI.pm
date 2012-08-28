package CFS::GoogleAPI;

use strict;
use JSON qw(encode_json decode_json);
use Acme::JWT;
use LWP::UserAgent;
require CFS::GoogleOauthToken;
require CFS::GoogleOauthToken::Manager;


sub new {
	my $proto = shift;
	my %args = @_;

	my $class  = ref $proto || $proto;

	my $m = {
		service_base => $args{service_base} || 'https://www.googleapis.com/prediction/v1.5/trainedmodels',
		auth_iss => $args{client_id} || '',
		auth_scope => $args{auth_scope} || 'https://www.googleapis.com/auth/prediction',
		auth_url => $args{auth_url} || 'https://accounts.google.com/o/oauth2/token',
		auth_ssl_key => $args{auth_ssl_key} || '',
		auth_ssl_crt => $args{auth_ssl_crt} || '',
		cfsdb => $args{cfsdb_handle} || undef,
		token => undef,
		models => {},
		lwp => LWP::UserAgent->new(keep_alive => 1)
	};

	# extract client id
	unless ( $m->{auth_iss} ) {
		open ID_FILE, $ENV{HOME}.'/.google-api.id' or die "Failed to open ~/.google-api.id";
		my $input = <ID_FILE> || '';
		close ID_FILE;
		chomp $input;
		die "~/.google-api.id empty?" unless $input;
		$m->{auth_iss} = $input;
	}

	unless ( $m->{cfsdb} ) {
		$m->{cfsdb} = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die
	}

	my $count = CFS::GoogleOauthToken::Manager->delete_google_oauth_tokens( db => $m->{cfsdb},
		where => [ expires => { lt => time } ]
	);

	bless ($m, $class);

	$m->load_token() or die "load_token() failed";

	$m->{models} = $m->google_prediction_request('list') or die "model listing failed";

	$m->model_id($args{model_id}) if $args{model_id};
	
	return $m;
}

sub google_prediction_request() {

	my $m = shift;
	my $action = lc shift or return;
	my %request_args = @_;

	my $url = $m->{service_base};
	my $method = '';

	if ( $action eq 'list' ) {
		$method = 'GET';
		$url .= '/list';

	} elsif ( $action eq 'get' || $action eq 'analyze' ) {
		$method = 'GET';
		unless ( $m->{model_id} ) {
			warn "Cannot process $action request without a model_id";
			return 0;
		}
		$url .= '/'.$m->{model_id};
		$url .= '/analyze' if $action eq 'analyze';

	} elsif ( $action eq 'insert' ) {
		$method = 'POST';
		unless ( %request_args ) {
			warn "Cannot process $action request without a request args";
			return 0;
		}

	} elsif ( $action eq 'predict' ) {
		$method = 'POST';
		unless ( $m->{model_id} ) {
			warn "Cannot process $action request without a model_id";
			return 0;
		}
		unless ( %request_args ) {
			warn "Cannot process $action request without a request args";
			return 0;
		}
		$url .= '/'.$m->{model_id}.'/predict';

	} elsif ( $action eq 'update' ) {
		$method = 'PUT';
		unless ( $m->{model_id} ) {
			warn "Cannot process $action request without a model_id";
			return 0;
		}
		unless ( %request_args ) {
			warn "Cannot process $action request without a request args";
			return 0;
		}
		$url .= '/'.$m->{model_id};

	} elsif ( $action eq 'delete' ) {
		$method = 'DELETE';
		unless ( $m->{model_id} ) {
			warn "Cannot process $action request without a model_id";
			return 0;
		}
		$url .= '/'.$m->{model_id};

	} else {
		warn "Unknown Google prediction action: $action";
		return 0;
	}

	my $lwp = $m->{lwp} || LWP::UserAgent->new(keep_alive => 1);
	my $req = HTTP::Request->new($method => $url);
	$req->header( 'Authorization' => 'Bearer '.$m->{token} );

	if ( %request_args ) {
		$req->content_type( 'application/json; charset=UTF-8' );
		my $json = encode_json(\%request_args);
		print "$method $url\n";
		print "$json\n\n";
		$req->content($json);
	}

	## trace debugging
	#$lwp->add_handler('request_send',  sub { print "--- REQUEST ---\n";  shift->dump; print "--- END ---\n"; return } );
	#$lwp->add_handler('response_done', sub { print "--- RESPONSE ---\n"; shift->dump; print "--- END ---\n"; return } );

	my $response = $lwp->request($req);
	unless ( $response->is_success ) {
		warn "API Request failed:  ".$response->status_line."\n".($response->content||'')."\n";
		return 0;
	}

	return decode_json($response->content) if $response->content;
	return;
}

sub predict() {
	my $m = shift;
	my @csv = @_;
	if ( scalar @csv == 1 ) {
		warn "CSV IS SCALAR";
		$csv[0] =~ s/['"]//go;
		@csv = split /,/, $csv[0];
	}
	foreach ( my $i = 0; $i < scalar @csv; $i++ ) {
		$csv[$i] += 0 if $csv[$i] =~ m/^(-)?(\d+|\d+[.]\d+|[.]\d+)$/o;
	}

	my $hashref = $m->google_prediction_request('predict', input => { csvInstance => [@csv] }) or return undef;
	return $hashref->{outputValue};
}

sub print_model_list() {
	my $m = shift;
	my $hashref = $m->google_prediction_request('list');

	foreach my $i ( @{$m->{models}->{items}} ) {
		printf "%-32s%s\n", $i->{id}, $i->{trainingStatus};
	}
}

sub train_model() {
	my $m = shift;
	my $id = shift or return 1;
	my $data_loc = shift or return 1;
	return $m->google_prediction_request('insert', id => $id, storageDataLocation => $data_loc);
}

sub delete_model() {
	my $m = shift;
	return $m->google_prediction_request('delete');
}

sub model_id() {
	my $m = shift;
	my $new_model_id = shift || '';

	if ( $new_model_id ){
		my $found_model = 0;
		foreach my $i ( @{$m->{models}->{items}} ) {
			$found_model = 1 if $new_model_id eq $i->{id};
		}
		unless ( $found_model ) {
			warn "Unknown Model Id: $new_model_id";
			return undef;
		}
		$m->{model_id} = $new_model_id;
	}
	return $m->{model_id};
}

sub load_token() {

	my $m = shift;
	return 1 if $m->{token};

	my $token = CFS::GoogleOauthToken->new(db => $m->{cfsdb}, id => 'cli');
	if ( $token->load(speculative => 1) ) {
		$m->{token} = $token->token();
		return 1;
	}

	my $issue_ts = time - 10;
	my $expire_ts = $issue_ts + 3600;
	my $jwt = Acme::JWT->encode(
		{ iss => $m->{auth_iss}, scope => $m->{auth_scope},
		  aud => $m->{auth_url}, iat => $issue_ts, exp => $expire_ts},
		$m->get_key(), 'RS256' );

	my $lwp = $m->{lwp} || LWP::UserAgent->new(keep_alive => 1);
	my $req = HTTP::Request->new(POST => $m->{auth_url});
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=$jwt");

	my $response = $lwp->request($req);

	die "OAuth2 Request failed:  ".$response->status_line."\n".($response->content||'')."\n"
		unless $response->is_success;

	my $res = decode_json($response->content);

	die "No access token in OAuth2 Response: \n".$response->content unless $res->{access_token};
	die "Unknown token_type in OAuth2 Response: \n".$response->content unless $res->{token_type} eq 'Bearer';
	die "Can't parse expires_in in OAuth2 Response: \n".$response->content unless $res->{expires_in} =~ m/^\d+$/o;

	$token->token($res->{access_token});
	$token->expires(time + $res->{expires_in} - 60);
	$token->save();

	$m->{token} = $token->token();
	return 1;
}


## ghetto key management - this needs love
sub get_key() {
	my $m = shift;
	return $m->{auth_ssl_key} if $m->{auth_ssl_key};

	# extract ssl key
	open ID_FILE, $ENV{HOME}.'/.google-api.key' or die "Failed to open ~/.google-api.key";
	my $input = <ID_FILE> || '';
	close ID_FILE;
	chomp $input;
	die "~/.google-api.key empty?" unless $input;
	$m->{auth_ssl_key} = $input;
	return $m->{auth_ssl_key};
}

sub get_cert() {
	my $m = shift;
	return $m->{auth_ssl_crt} if $m->{auth_ssl_crt};

	# extract ssl cert
	open ID_FILE, $ENV{HOME}.'/.google-api.crt' or die "Failed to open ~/.google-api.crt";
	my $input = <ID_FILE> || '';
	close ID_FILE;
	chomp $input;
	die "~/.google-api.crt empty?" unless $input;
	$m->{auth_ssl_crt} = $input;
	return $m->{auth_ssl_crt};
}


1;
