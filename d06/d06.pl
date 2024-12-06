#!/usr/bin/env perl

use v5.38;

open(my $input, "<", "input.txt");
#open(my $input, "<", "sample.txt");

my $p01 = 0;
my $p02 = 0;

my @barriers_input;
my $guard_init_x;
my $guard_init_y;

while (<$input>) {
	# find the guard!
	if (/\^/) {
		my ($l, $guard) = /^([^^]+)(\^)/;
		$guard_init_x = length($l);
		$guard_init_y = @barriers_input;
	}

	# strings of non-barrier thingies
	my @nonbarriers = split '#';

	# drop the last entry because theres no barrier after it.
	pop @nonbarriers;

	# generate a list of barrier positions.
	my @barriers;
	my $x = 0;
	for my ($sep) (@nonbarriers) {
		# space before the barrier
		$x += length $sep;

		# barrier location
		push(@barriers, $x);

		# increment to account for barrier location
		$x++;
	}
	push(@barriers_input, \@barriers);
}


sub checkmap {
	my @barriers_row = @_;
	my @barriers_col;

	my $guard_x = $guard_init_x;
	my $guard_y = $guard_init_y;
	my $guard_dir = "up";

	# transpose to generate barriers by column
	for (my $x = 0; $x < @barriers_row; $x++) {
		my @col;
		for (my $y = 0; $y < @barriers_row; $y++) {
			push(@col, $y) if grep { $_ == $x } @{$barriers_row[$y]}
		}
		push(@barriers_col, \@col);
	}

	# we need reverse for searching for highest-low
	my @barriers_row_rev;
	for my ($barriers) (@barriers_row) {
		my @rev = reverse @{$barriers};
		push(@barriers_row_rev, \@rev);
	}
	my @barriers_col_rev;
	for my ($barriers) (@barriers_col) {
		my @rev = reverse @{$barriers};
		push(@barriers_col_rev, \@rev);
	}

	# these should be the same
	my $w = @barriers_col;
	my $h = @barriers_row;

	# set of places the guard has traversed. key: $x,$y
	# initialized with guard position
	my %heatmap = (
		"$guard_x,$guard_y", 1
	);

	# set of places the guard has stopped. first step doesnt count
	my %guard_history;

	# move the guard around and do the mapping
#	for (my $iter = 1; $iter < 1000; $iter++) {
	while (1) {
		my $box;
		if ($guard_dir eq "up") {
			# find the lowest-y barrier on the current column
			($box) = grep { $_ < $guard_y } @{$barriers_col_rev[$guard_x]};
			$box = -1 unless defined $box;

			for (my $y = $guard_y; $y > $box; $y--) {
				$heatmap{"$guard_x,$y"} = 1;
			}

			# guard is here now
			$guard_y = $box + 1;
			$guard_dir = "right";
		} elsif ($guard_dir eq "down") {
			($box) = grep { $_ > $guard_y } @{$barriers_col[$guard_x]};
			$box = $h unless defined $box;

			for (my $y = $guard_y; $y < $box; $y++) {
				$heatmap{"$guard_x,$y"} = 1;
			}

			# guard is here now
			$guard_y = $box - 1;
			$guard_dir = "left";
		} elsif ($guard_dir eq "left") {
			# find the lowest-x barrier on the current column
			($box) = grep { $_ < $guard_x } @{$barriers_row_rev[$guard_y]};
			$box = -1 unless defined $box;

			for (my $x = $guard_x; $x > $box; $x--) {
				$heatmap{"$x,$guard_y"} = 1;
			}

			# guard is here now
			$guard_x = $box + 1;
			$guard_dir = "up";
		} elsif ($guard_dir eq "right") {
			($box) = grep { $_ > $guard_x } @{$barriers_row[$guard_y]};
			$box = $w unless defined $box;

			for (my $x = $guard_x; $x < $box; $x++) {
				$heatmap{"$x,$guard_y"} = 1;
			}

			# guard is here now
			$guard_x = $box - 1;
			$guard_dir = "down";
		}

		# have we been here before, in this direction?
		my $past = $guard_history{"$guard_x,$guard_y"};
		$past = "" unless $past;
		return -1 if index($past, $guard_dir) != -1;
		$guard_history{"$guard_x,$guard_y"} = "$past $guard_dir";

		last if $box < 0 or $box >= $w;
	}

	my $traversed = values %heatmap;
	return $traversed;
}

sub ins_box {
	my ($x, $y) = @_;

	# clone
	my @barriers = @barriers_input;

	my @mod = @{$barriers[$y]};

	push(@mod, $x);
	@mod = sort @mod;
	$barriers[$y] = \@mod;
	return @barriers;
}

$p01 = checkmap(@barriers_input);

# brute force of shame. it also doesnt work so. welp
my %loop_boxes;
for (my $x = 0; $x < @barriers_input; $x++) {
	for (my $y = 0; $y < @barriers_input; $y++) {
		say "$x, $y";
		my @mod = ins_box($x, $y);
		if (checkmap(@mod) == -1) {
			$loop_boxes{"$x,$y"} = 1;
			say "found one";
		}
	}
}

$p02 = values %loop_boxes;




# ======
#  I tried not to brute force it but never quite got it working. it works
#  on the demo input but not on the real thing.
# ======
#my %loop_boxes;
#
## Now check the guard history for intersections
#for (my $i = 6; $i < @guard_history - 3; $i += 3) {
#	# we need to fill in the rectangle. so we need the intersection of
#	# our current path and our path 3 moves ago
#	my $x = $guard_history[$i];
#	my $y = $guard_history[$i + 1];
#	my $dir = $guard_history[$i + 2];
#	my $next_x = $guard_history[$i + 3];
#	my $next_y = $guard_history[$i + 4];
##	$next_x = 0 unless defined $next_x;
##	$next_y = 0 unless defined $next_y;
#
#	for (my $past_i = $i - 6; $past_i >= 0; $past_i -= 12) {
#		my $past_x = $guard_history[$past_i];
#		my $past_y = $guard_history[$past_i + 1];
#
#		my $box_x;
#		my $box_y;
#		# intersection depends on what direction we're pointing
#		# BUT we dont get an intersection if we would have hit another
#		# box first
#
#		if ($dir eq "up") {
#			$box_x = $x;
#			$box_y = $past_y - 1;
#			next if $past_y > $y;
#			next if $box_y < $next_y;
#		} elsif ($dir eq "down") {
#			$box_x = $x;
#			$box_y = $past_y + 1;
#			next if $past_y < $y;
#			next if $box_y > $next_y;
#		} elsif ($dir eq "left") {
#			# failing option 5
#			$box_x = $past_x - 1;
#			$box_y = $y;
#			next if $past_x > $x;
#			next if $box_x < $next_x;
#		} elsif ($dir eq "right") {
#			$box_x = $past_x + 1;
#			$box_y = $y;
#			next if $past_x < $x;
#			next if $box_x > $next_x;
#		}
#
#		if ($box_x >= 0 and $box_x < $w and $box_y >= 0 and $box_y < $h) {
#			$loop_boxes{"$box_x,$box_y"} = 1;
#		}
#	}
#}

#my @k = sort(keys %loop_boxes);
#say "@k";

# 162 is too low
# 1524 is too low
# 799 is wrong
#$p02 = values %loop_boxes;


say "p01: $p01";
say "p02: $p02";
