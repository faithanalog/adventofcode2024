#!/usr/bin/env perl

use List::MoreUtils qw(zip);

use v5.38;

open(my $input, "<", "input.txt");

my @left;
my @right;
while (<$input>) {
	my ($l, $r) = /([0-9]+)\s+([0-9]+)/ or next;
	push(@left, $l);
	push(@right, $r);
}

@left = sort @left;
@right = sort @right;

my @pairs = zip @left, @right;

my $p01 = 0;
for my ($l, $r) (@pairs) {
	$p01 += abs($l - $r);
}

say "Day 01p1: ${p01}";


my %frequencies;

for my $r (@right) {
	$frequencies{$r}++;
}

my $p02 = 0;
for my $l (@left) {
	my $freq = ($frequencies{$l} or 0);
	$p02 += $l * $freq;
}

say "Day 01p2: ${p02}";


