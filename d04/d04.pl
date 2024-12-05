#!/usr/bin/env perl

use v5.38;

open(my $input, "<", "input.txt");
#open(my $input, "<", "sample.txt");

my $p01 = 0;
my $p02 = 0;

my @chrs;

my $height = 0;
while (<$input>) {
	next unless /[XMAS\.]/;
	my ($ln) = /([XMAS\.]+)/;
	push(@chrs, split '', $ln);
	$height++;
}

my $width = @chrs / $height;

sub chrat {
	my ($x, $y) = @_;
	if ($y >= $height or $x >= $width) {
		return "";
	} else {
		return $chrs[$x + $y * $width];
	}
}

for (my $y = 0; $y < $height; $y++) {
	for (my $x = 0; $x < $width; $x++) {
		my @str = (
			chrat($x + 0, $y),
			chrat($x + 1, $y),
			chrat($x + 2, $y),
			chrat($x + 3, $y),
		);
		$p01++ if ( ( "@str" eq "X M A S" ) or ( "@str" eq "S A M X" ) );

		@str = (
			chrat($x, $y + 0),
			chrat($x, $y + 1),
			chrat($x, $y + 2),
			chrat($x, $y + 3),
		);
		$p01++ if ( ( "@str" eq "X M A S" ) or ( "@str" eq "S A M X" ) );

		@str = (
			chrat($x + 0, $y + 0),
			chrat($x + 1, $y + 1),
			chrat($x + 2, $y + 2),
			chrat($x + 3, $y + 3),
		);
		$p01++ if ( ( "@str" eq "X M A S" ) or ( "@str" eq "S A M X" ) );

		@str = (
			chrat($x + 0, $y + 3),
			chrat($x + 1, $y + 2),
			chrat($x + 2, $y + 1),
			chrat($x + 3, $y + 0),
		);
		$p01++ if ( ( "@str" eq "X M A S" ) or ( "@str" eq "S A M X" ) );
	}
}

for (my $y = 0; $y < $height; $y++) {
	for (my $x = 0; $x < $width; $x++) {
		my @str = (
			chrat($x + 0, $y + 0),
			chrat($x + 1, $y + 1),
			chrat($x + 2, $y + 2),
		);
		my $xm1 = ( ( "@str" eq "M A S" ) or ( "@str" eq "S A M" ) );

		@str = (
			chrat($x + 0, $y + 2),
			chrat($x + 1, $y + 1),
			chrat($x + 2, $y + 0),
		);
		my $xm2 = ( ( "@str" eq "M A S" ) or ( "@str" eq "S A M" ) );

		$p02++ if ($xm1 and $xm2);
	}
}

say "p01: $p01";
say "p02: $p02";
