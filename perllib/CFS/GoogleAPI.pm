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
		auth_iss => $args{client_id} || '140408034834@developer.gserviceaccount.com',
		auth_scope => $args{auth_scope} || 'https://www.googleapis.com/auth/prediction',
		auth_url => $args{auth_url} || 'https://accounts.google.com/o/oauth2/token',
		cfsdb => $args{cfsdb_handle} || undef,
		token => undef,
		models => {},
		lwp => LWP::UserAgent->new
	};

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

	my $lwp = $m->{lwp} || LWP::UserAgent->new;
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
		$csv[0] =~ s/['"]//go;
		@csv = split /,/, $csv[0];
	}
	foreach ( my $i = 0; $i < scalar @csv; $i++ ) {
		$csv[$i] += 0 if $csv[$i] =~ m/^(-)?(\d+|\d+[.]\d+|[.]\d+)$/o;
	}
	#my $csv = shift or return 1;
	#$csv =~ s/"/'/go;

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
		die "Unknown Model Id: $new_model_id" unless $found_model;
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

	my $issue_ts = time;
	my $expire_ts = $issue_ts + 3600;
	my $jwt = Acme::JWT->encode(
		{ iss => $m->{auth_iss}, scope => $m->{auth_scope},
		  aud => $m->{auth_url}, iat => $issue_ts, exp => $expire_ts},
		get_key(), 'RS256' );

	my $lwp = $m->{lwp} || LWP::UserAgent->new;
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


## ghetto key management
sub get_key() {
	return '-----BEGIN PRIVATE KEY-----
MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAObmRgu+18i2NjWE
0rr9GefOxlduix5AaO9u6JN0Zs++c8UliTHrN9PEtSHZCcHZ5ktQb8PPke1zHD2k
3sVHtgbJM1oV7tBmBK//Jr3oruySyaRhq/CJfrYBpiX2gHo3G2emsJuelc0WWXyJ
SZAtG2rt6mJUvNNbdk8DupwPtaLXAgMBAAECgYEAyzM905pY9kb8v+6rMWoKgUkk
nc8n2TCf6I63WQUocYzO/2HAMlEpqVFEgowpnRKxK/iW00D50HjsEofkkMNCOVwg
ybMrqgY/hHycBn4LzvpIa7e5V8Ly+GfmtMEgnE8hy3iI8WZX3/inZ8XZPYt5SZ+K
qvl1Ke9sn63cQ860HGkCQQD/uIrJjp7sX1isQT+RnVQ2F3HiWd+QQODcKsi7oA7h
5uvv3cmbturOR5qOZ8u//XATYoVcxiDj9C8CkHuGx5EdAkEA5ybLpBz8j+83CVGh
26VYS0OAWvaULeKiXBqF3eBIv3Y1VU3g0Tx8LlZVfHtjQrzLfmw1PoUi93RsImbK
szsVgwJBAMTUOp9hk5nE2e/cWR2vx33LFfFv09Co32sX02H3lPz0TW5XfDLK3Hji
TGiIJCAm5vlEv/nk1rQe44BJzYq0WVECQQC45eCJMyKX4+rrSmAleVpqQeF/YbRg
C+SBtjmUpJ6sgFrjFHucAzz2N9sDyxM4RBqm0tm4W/j/ZiJFVmIYAlAPAkAIK/23
ncxVIz62jOri/370sicg4ur1BHf08eisMS36zlCgSy3N55hs31w8VLZTUz7TGwSa
t+EPthm63aPoQUhD
-----END PRIVATE KEY-----';
}

sub get_cert() {
	return '-----BEGIN CERTIFICATE-----
MIICGTCCAYKgAwIBAgIIUJcO4IeH3uEwDQYJKoZIhvcNAQEFBQAwMjEwMC4GA1UE
AxMnMTQwNDA4MDM0ODM0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tMB4XDTEy
MDgyMDAxMTgyNFoXDTIyMDgxODAxMTgyNFowMjEwMC4GA1UEAxMnMTQwNDA4MDM0
ODM0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tMIGfMA0GCSqGSIb3DQEBAQUA
A4GNADCBiQKBgQDm5kYLvtfItjY1hNK6/RnnzsZXboseQGjvbuiTdGbPvnPFJYkx
6zfTxLUh2QnB2eZLUG/Dz5Htcxw9pN7FR7YGyTNaFe7QZgSv/ya96K7sksmkYavw
iX62AaYl9oB6NxtnprCbnpXNFll8iUmQLRtq7epiVLzTW3ZPA7qcD7Wi1wIDAQAB
ozgwNjAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAK
BggrBgEFBQcDAjANBgkqhkiG9w0BAQUFAAOBgQCOWdH4MdBQFVz+l39p9Vo3qQaA
ab+8+0aUpHoBpltLcuj52NDNlcpeQ+reTG5QunQlw2PScXBvvwsa4m5rbgLWoZAO
tpFPMfkg2uFuFjt+IHX+feyiP74G+W9yXrj8jXcavYHr01Thw9O/meK/6RKi0zpJ
AvJASHvlDUJeOJ1YUw==
-----END CERTIFICATE-----';
}


1;
