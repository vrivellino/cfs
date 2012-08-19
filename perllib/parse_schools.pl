#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::School;

my $cfsdb = CFS::DB->new(default_connect_options=>{RaiseError=>1,PrintError=>1}) or die;

# convert to CSV
my @content = <>;
my $content = join '', @content;
$content =~ s/[\r\n]//go;

$content =~ s/^.*table class="sortable  stats_table" id="schools"[>]//o;
$content =~ s/[<]\/table[>].*$//o;

$content =~ s/[<]colgroup[>].*[<]\/colgroup[>]//o;
$content =~ s/[<]thead[>].*[<]\/thead[>]//o;
$content =~ s/[<][\/]?tbody[>]//go;

$content =~ s/[>]\s+[<]/></go;

$content =~ s/[<]\/tr[>]/\n/go;
$content =~ s/[<]tr class="no_ranker thead over_header"[>][^\n]+\n//go;
$content =~ s/[<]tr class="no_ranker thead"[>][^\n]+\n//go;

$content =~ s/[<]tr  class=""[>]//go;
$content =~ s/[<]td[^>]*[>]//go;
$content =~ s/[<]\/td[^>]*[>]/,/go;

$content =~ s/[<]a href="([^"]+)"[>]([^<]+)[<]\/a[>]/$2,$1/go;

# extract each school
my @csv = split /\n/, $content;
while ( my $school = shift @csv ) {
	my ($n, $name, $url, $yr1, $yr2, $yrs, $gm, $w, $l, $t, $pct, $b_gm, $b_w, $b_l, $b_t, $b_pct, $srs, $sos, $ap, $cc, $notes ) = split /,/, $school
		or warn "Failed to parse: $school\n";
	next unless $n;

	$name =~ s/[&]amp;/&/o;

	my @cur_date = localtime;
	my $cur_yr = 1900+$cur_date[5];

	$yr1 = 1901 if $yr1 < 1901;
	$yr2 = $cur_yr if $yr2 > $cur_yr;

	my $school_record = CFS::School->new( db => $cfsdb,
		name => $name,
		yr_from => $yr1,
		yr_to => $yr2,
		yrs => $yrs,
		games => $gm,
		win => $w,
		loss => $l,
		tie => $l,
		pct => $pct,
		bowls => $b_gm,
		bowl_win => $b_w,
		bowl_loss => $b_l,
		bowl_tie => $b_t,
		bowl_pct => $b_pct,
		sr_srs => $srs,
		sr_sos => $sos,
		ap_yrs => $ap,
		conf_champs => $cc,
		notes => $notes
	);
	$school_record->save();
}
