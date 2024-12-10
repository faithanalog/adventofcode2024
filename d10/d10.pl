#!/usr/bin/env perl

use v5.38;

open(my $input, "<", "input.txt");
#open(my $input, "<", "sample.txt");

my $p01 = 0;
my $p02 = 0;

my @terrain;
my @trailheads;

sub tile {
	my ($x, $y) = @_;

	return -1 if $x < 0 or $x >= @terrain or $y < 0 or $y >= @terrain;
	return $terrain[$y][$x];
}

while (<$input>) {
	my $y = @terrain;

	chomp;
	my @row = split '';
	push(@terrain, \@row);

	# trailheads on this col
	my @not_trailheads = split '0', "$_.";
	pop(@not_trailheads);
	my $x = 0;
	for my ($str) (@not_trailheads) {
		$x += length($str);
		push(@trailheads, ($x, $y));
		$x++;
	}
}

for my ($x, $y) (@trailheads) {
	my $paths = [ $x, $y ];

	my %peaks;
	my $peak_paths = 0;

	while (@$paths > 0) {
		my $new_paths = [ ];
		for my ($px, $py) (@$paths) {
			my $height = tile($px, $py);
			$peaks{"$px,$py"} = 1 if $height == 9;
			$peak_paths++ if $height == 9;
			push(@$new_paths, ($px + 0, $py - 1)) if tile($px + 0, $py - 1) == $height + 1;
			push(@$new_paths, ($px - 1, $py + 0)) if tile($px - 1, $py + 0) == $height + 1;
			push(@$new_paths, ($px + 1, $py + 0)) if tile($px + 1, $py + 0) == $height + 1;
			push(@$new_paths, ($px + 0, $py + 1)) if tile($px + 0, $py + 1) == $height + 1;
		}
		$paths = $new_paths;
	}

	my @peaks = values %peaks;
	$p01 += @peaks;
	$p02 += $peak_paths;

}

say "p01: $p01";
say "p02: $p02";
