#!/usr/bin/perl

use strict;
use warnings;

require CFS::DB;
require CFS::School;
require CFS::SchoolNameOverride;

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

# print csv (needed by fetch-stats)
print $content;

my @cur_date = localtime;
my $cur_yr = 1900+$cur_date[5];

# create stub record
my $school_record = CFS::School->new( db => $cfsdb,
		name => 'FCS School',
		yr_from => '0000',
		yr_to => '0000',
		notes => 'Generic FCS School'
	);
$school_record->save();

# extract each school
my @csv = split /\n/, $content;
while ( my $school = shift @csv ) {
	my ($n, $name, $url, $yr1, $yr2, $yrs, $gm, $w, $l, $t, $pct, $b_gm, $b_w, $b_l, $b_t, $b_pct, $srs, $sos, $ap, $cc, $notes ) = split /,/, $school
		or warn "Failed to parse: $school\n";
	next unless $n;

	$name =~ s/[&]amp;/&/o;

	my $name_override = CFS::SchoolNameOverride->new( db => $cfsdb, original_name => $name );
	$name = $name_override->name if $name_override->load( speculative => 1 );

	$yr1 = 1901 if $yr1 < 1901;
	$yr2 = $cur_yr if $yr2 > $cur_yr;

	$school_record = CFS::School->new( db => $cfsdb,
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

# known FCS schools
my @fcs_schools = ( 'Tennessee-Martin', 'Murray State', 'Georgia Southern', 'Northern Iowa', 'Western Illinois', 'Eastern Washington',
'Southeast Missouri State', 'Youngstown State', 'Liberty', 'Northeastern', 'Sacramento State', 'Tennessee Tech', 'Weber State',
'Portland State', 'Morgan State', 'North Carolina A&T', 'Eastern Illinois', 'Missouri State', 'James Madison', 'Virginia Union',
'Stephen F. Austin', 'Nicholls State', 'Savannah State', 'Eastern Kentucky', 'Delaware', 'Bethune-Cookman', 'Edward Waters',
'Cal Poly', 'Sam Houston State', 'Jacksonville State', 'California-Davis', 'Southeastern Louisiana', 'Rhode Island', 'Alabama State',
'Hofstra', 'North Dakota State', 'Howard', 'Southern Utah', 'South Carolina State', 'Central Arkansas', 'Gardner-Webb', 'Elon',
'West Virginia Tech', 'Delaware State', 'Norfolk State', 'Charleston Southern', 'Central Connecticut State', 'Arkansas-Pine Bluff',
'North Carolina Central', 'Morehead State', 'South Dakota State', 'Towson', 'Coastal Carolina', 'Alabama A&M', 'North Dakota', 'Hampton',
'South Dakota', 'Stony Brook', 'Austin Peay', 'Georgia State', 'Wagner', 'Northwestern Oklahoma State', 'Texas A&M-Commerce' );

foreach my $fcs_name ( @fcs_schools ) {
	$school_record = CFS::School->new( db => $cfsdb,
		name => $fcs_name, yr_from => '0000', yr_to => '0000', notes => 'FCS School' );

	$school_record->save();
}
