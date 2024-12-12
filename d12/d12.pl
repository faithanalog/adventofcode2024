#!/usr/bin/env perl

# I'm writing today's solution on an older machine today.
#use Modern::Perl;
use v5.28;

open(my $input, "<", "input.txt");
#open(my $input, "<", "sample.txt");
#open(my $input, "<", "e.txt");

my $p01 = 0;
my $p02 = 0;


my @map;
my @regions;
my @region_letters;
my $w = 0;
my $h = 0;
while (<$input>) {
	next unless /[A-Z]/;
	chomp;
	my @seq = split '';
	$w = @seq;
	$h++;
	push(@map, @seq);
}

# We will use negative numbers to indicate regions we haven't mapped
# out yet.
my $letter_a = ord("A");
@map = map { -( ord($_) - $letter_a + 1 ) } @map;

sub idx {
	my ($x, $y) = @_;
	return -1 if $x < 0 or $x >= $w;
	return -1 if $y < 0 or $y >= $h;
	return $x + $y * $w;
}

sub get {
	my ($x, $y) = @_;
	return 0 if $x < 0 or $x >= $w;
	return 0 if $y < 0 or $y >= $h;
	return $map[$x + $y * $w];
}

sub set {
	my ($x, $y, $v) = @_;
	return if $x < 0 or $x >= $w;
	return if $y < 0 or $y >= $h;
	$map[$x + $y * $w] = $v;
}

sub floodfill {
	my ($x_start, $y_start, $rid) = @_;

	my $crop = get($x_start, $y_start);

	# for debugging only
	$region_letters[$rid] = chr(-$crop - 1 + ord('A'));

	my @queue = (
		$x_start, $x_start, $y_start, 1,
		$x_start, $x_start, $y_start - 1, -1,
	);

	my @spans;

	while (@queue) {
		my ($x1, $x2, $y, $dy) = splice(@queue, -4);
		my $x = $x1;

		if (get($x, $y) == $crop) {
			my $span_x = $x - 1;
			my $span_len = 0;

			my $idx = idx($x - 1, $y);
			while ($x - 1 >= 0 and $map[$idx] == $crop) {
				$map[$idx] = $rid;
				$x--;
				$idx--;

				# $x is now -1
				$span_x = $x;
				$span_len++;
			}

			if ($span_len > 0) {
				push(@spans, ($y, $span_x, $span_len));
			}

			if ($x < $x1) {
				push(@queue, ($x, $x1 - 1, $y - $dy, -$dy));
			}
		}

		while ($x1 <= $x2) {
			my $span_x = $x1;
			my $span_len = 0;

			my $idx = idx($x1, $y);
 
 			if ($idx != -1) {
	            while ($x1 < $w and $map[$idx] == $crop) {
	            	$map[$idx] = $rid;
	            	$x1++;
	            	$idx++;
	            	$span_len++;
	            }
            }

			if ($span_len > 0) {
				push(@spans, ($y, $span_x, $span_len));
			}

            if ($x1 > $x) {
            	push(@queue, ($x, $x1 - 1, $y + $dy, $dy));
            }
            if ($x1 - 1 > $x2) {
            	push(@queue, ($x2 + 1, $x1 - 1, $y - $dy, -$dy));
            }
            $x1++;

            while ($x1 < $x2 and get($x1, $y) != $crop) {
            	$x1++;
            }
            $x = $x1;
		}
	}

	$regions[$rid] = \@spans;
}

# region 0 should be empty
push(@regions, []);
push(@region_letters, '.');

my $idx = 0;
for (my $y = 0; $y < $h; $y++) {
	for (my $x = 0; $x < $w; $x++) {

		# This section of the map hasnt been filled yet. Fill with
		# a new region.
		if ($map[$idx] < 0) {
			floodfill($x, $y, scalar @regions);
		}
		$idx++;
	}
}

for (my $rid = 1; $rid < @regions; $rid++) {
	my $spans = $regions[$rid];

	my $area = 0;

	my @perimeter_horiz;
	my @perimeter_vert;

	for (my $i = 0; $i < @$spans; $i += 3) {
		my $y = @$spans[$i + 0];
		my $x0 = @$spans[$i + 1];
		my $len = @$spans[$i + 2];
		my $x1 = $x0 + $len - 1;

		# ez
		$area += $len;

		# Check X-edges
		push(@perimeter_vert, ($x0 - 0.25, $y)) if get($x0 - 1, $y) != $rid;
		push(@perimeter_vert, ($x1 + 0.25, $y)) if get($x1 + 1, $y) != $rid;

		# Check Y-edges for Y-perimeter
		my $x = $x0;
		while ($x <= $x1) {

			push(@perimeter_horiz, ($x, $y - 0.25)) if get($x, $y - 1) != $rid;
			push(@perimeter_horiz, ($x, $y + 0.25)) if get($x, $y + 1) != $rid;
			$x++;
		}
	}

	# perimeter div 2 because it has X and Y coordinates
	my $perimeter = (@perimeter_vert + @perimeter_horiz) >> 1;
	$p01 += $area * $perimeter;

	my $sides = 0;

	# Y-axis sides
	my @idxs;
	for (my $i = 0; $i < @perimeter_vert >> 1; $i++) {
		push(@idxs, $i);
	}
	# sort indices by perimeter_vert X axis, then Y axis
	@idxs = sort {
		my $l = $perimeter_vert[($a << 1)] * 65536;
		$l += $perimeter_vert[($a << 1) + 1];
		my $r = $perimeter_vert[($b << 1)] * 65536;
		$r += $perimeter_vert[($b << 1) + 1];

		$l <=> $r
	} @idxs;

	my $x = 999;
	my $y = 999;
	for (my $i = 0; $i < @idxs; $i++) {
		my $idx = $idxs[$i];
		my $xx = $perimeter_vert[($idx << 1)];
		my $yy = $perimeter_vert[($idx << 1) + 1];

		# side starts
		if ($xx != $x or $yy - $y > 1) {
			$sides++;
		}
		
		$x = $xx;
		$y = $yy;
	}

	# X-axis sides;
	my @idxs;
	for (my $i = 0; $i < @perimeter_horiz >> 1; $i++) {
		push(@idxs, $i);
	}
	# sort indices by perimeter Y axis, then X axis
	@idxs = sort {
		my $l = $perimeter_horiz[($a << 1)];
		$l += $perimeter_horiz[($a << 1) + 1] * 65536;
		my $r = $perimeter_horiz[($b << 1)];
		$r += $perimeter_horiz[($b << 1) + 1] * 65536;
		
		$l <=> $r
	} @idxs;

	my $x = 999;
	my $y = 999;
	for (my $i = 0; $i < @idxs; $i++) {
		my $idx = $idxs[$i];
		my $xx = $perimeter_horiz[($idx << 1)];
		my $yy = $perimeter_horiz[($idx << 1) + 1];

		# side starts
		if ($yy != $y or $xx - $x > 1) {
			$sides++;
		}
		$x = $xx;
		$y = $yy;
	}

	$p02 += $sides * $area;
}

say "p01: $p01";
say "p02: $p02";
