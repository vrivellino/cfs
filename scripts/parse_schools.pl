#!/usr/bin/perl

use strict;
use warnings;

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


print $content;
