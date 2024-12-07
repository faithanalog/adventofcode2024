#!/usr/bin/env perl

use v5.38;

open(my $input, "<", "input.txt");

my $p01 = 0;
my $p02 = 0;

while (<$input>) {
	my ($result, $x) = /^(\d+): (.+)/;
	my @vals = split ' ', $x;

	my $states = [ $vals[0] ];

	for (my $i = 1; $i < @vals; $i++) {
		my $new_states = [];
		my $v = $vals[$i];
		for my ($st) (@$states) {
			push(@$new_states, (
				$st * $v,
				$st + $v
			));
		}
		$states = $new_states;
	}

	if (grep { $_ == $result } @$states) {
		$p01 += $result;
		$p02 += $result;
		next;
	}

	$states = [ $vals[0] ];

	for (my $i = 1; $i < @vals; $i++) {
		my $new_states = [];
		my $v = $vals[$i];
		for my ($st) (@$states) {
			push(@$new_states, (
				$st * $v,
				$st + $v,
				"$st$v"
			));
		}
		$states = $new_states;
	}

	$p02 += $result if grep { $_ == $result } @$states;
}

say "p01: $p01";
say "p02: $p02";
