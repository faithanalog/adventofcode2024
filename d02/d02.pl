#!/usr/bin/env perl

use List::MoreUtils qw(zip any all pairwise);
use List::Util qw(head tail);

use v5.38;

open(my $input, "<", "input.txt");


sub is_safe {
	my @row = @_;

	my @l = head -1, @row;
	my @r = tail -1, @row;

	my @asc  = pairwise { $a < $b } @l, @r;
	my @desc = pairwise { $a > $b } @l, @r;
	my @diff = pairwise { abs($a - $b) } @l, @r;

	my $safe = 0;

	$safe = 1 if all { $_ } @asc;
	$safe = 1 if all { $_ } @desc;
	$safe = 0 if any { $_ < 1 or $_ > 3 } @diff;

	return $safe;
}

my $safe_count_p1 = 0;
my $safe_count_p2 = 0;

while (<$input>) {
	next unless /[0-9]/;
	my @row = split(/ /);

	my $safe = is_safe @row;

	$safe_count_p1 += $safe;
	$safe_count_p2 += $safe;

	unless ($safe) {
		for (my $i = 0; $i < @row; $i++) {
			my @copy = @row;
			splice @copy, $i, 1;
			if (is_safe @copy) {
				$safe_count_p2++;
				last;
			}
		}
	}
}

say "p01: $safe_count_p1";
say "p01: $safe_count_p2";

