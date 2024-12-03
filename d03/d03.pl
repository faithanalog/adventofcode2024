#!/usr/bin/env perl

use v5.38;

open(my $input, "<", "input.txt");

my $p01 = 0;
my $p02 = 0;

sub mult {
	my ($args) = @_;
	my ($l, $r) = $args =~ /(\d+),(\d+)/;
	$l * $r;
}

while (<$input>) {
	my @instrs = /(mul|do|don't)\((\d+,\d+|)\)/g;
	for my ($op, $args) (@instrs) {
		$p01 += mult($args) if $op eq "mul";
		unless (($op eq "don't") .. ($op eq "do")) {
			$p02 += mult($args) if $op eq "mul";
		}
	}
}

say "p01: $p01";
say "p02: $p02";
