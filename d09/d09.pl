#!/usr/bin/env perl

use v5.38;

use List::Util qw(sum);

open(my $input, "<", "input.txt");
#open(my $input, "<", "sample.txt");

my $p01 = 0;
my $p02 = 0;


sub do_p01 {
	my @blocks = @_;
	# Fragment the filesystem
	my $head = 0;
	my $tail = @blocks - 1;
	while ($head < $tail) {
		if ($blocks[$tail] == -1) {
			$tail--;
			next;
		}

		if ($blocks[$head] == -1) {
			$blocks[$head] = $blocks[$tail];
			$blocks[$tail] = -1;
			$tail--;
		}
		$head++;
	}

	# Calculate p01
	for (my $i = 0; $i < @blocks; $i++) {
		$p01 += $i * $blocks[$i] if $blocks[$i] > 0;
	}
}

# this is actually better at compacting while avoiding fragmentation. it results
# in less block device use over all and runs way way faster. but its not to spec
sub do_p02_but_better {
	my @blocks = @_;

	# This time we move whole files

	# Index of files waiting for a spot
	my @waiting_files;

	my $tail_file_len = 0;

	
	my $head = 0;
	my $tail = @blocks - 1;
	my $prev = $blocks[@blocks - 1];
	while ($tail >= 0) {
		# Find the start of the file
		if ($blocks[$tail] == $prev) {
			$tail_file_len++;
		} else {
			if ($prev != -1) {
				# index
				push(@waiting_files, $tail + 1);
				
				# length
				push(@waiting_files, $tail_file_len);
			}
			$tail_file_len = 1;
		}
		$prev = $blocks[$tail];
		$tail--;
	}

	my $free_len = 0;
	while ($head < @blocks and @waiting_files > 0) {
		# Move a block in
		if ($blocks[$head] > -1) {
			if ($free_len > 0) {
				my $found_one = 0;
				for (my $i = 0; $i < @waiting_files; $i += 2) {
					if ($waiting_files[$i + 1] <= $free_len) {
						# found a file to put in
						my ($from, $len) = splice(@waiting_files, $i, 2);

						my $to = $head - $free_len;
						for (my $j = 0; $j < $len; $j++) {
							$blocks[$to + $j] = $blocks[$from + $j];
							$blocks[$from + $j] = -1;
						}
						$free_len -= $len;
						$found_one = 1;
						last;
					}
				}
				# dont inc head, do another allocation
				next if $found_one;
			}
		}
		
		# Get the length of freespace
		if ($blocks[$head] == -1) {
			$free_len++;
		}
		$head++;
	}

	# Calculate p01
	for (my $i = 0; $i < @blocks; $i++) {
		$p02 += $i * $blocks[$i] if $blocks[$i] > 0;
	}
}


sub do_p02 {
	my @blocks = @_;

	# This time we move whole files

	# Index of files waiting for a spot
	my @waiting_files;

	my $tail_file_len = 0;

	
	my $head = 0;
	my $tail = @blocks - 1;
	my $prev = $blocks[@blocks - 1];
	while ($tail >= 0) {
		# Find the start of the file
		if ($blocks[$tail] == $prev) {
			$tail_file_len++;
		} else {
			if ($prev != -1) {
				# index
				push(@waiting_files, $tail + 1);
				
				# length
				push(@waiting_files, $tail_file_len);
			}
			$tail_file_len = 1;
		}
		$prev = $blocks[$tail];
		$tail--;
	}

	my $free_len = 0;
	# $head tracks the earliest empty spot
	while ($head < @blocks and @waiting_files > 0) {
		#advance $head to earliest empty spot
		if ($blocks[$head] != -1) {
			$head++;
			next;
		}

		# allocate the current waiting file, if we can move it at all
		my $from = shift @waiting_files;
		my $len = shift @waiting_files;


		my $gap_start;
		my $gap_len = 0;
		for (my $i = $head; $i < @blocks; $i++) {
			if ($blocks[$i] == -1) {
				$gap_start = $i if $gap_len == 0;
				$gap_len++;
			} else {
				$gap_len = 0;
			}

			if ($gap_len >= $len) {
				# dont move files forward
				if ($from < $gap_start) {
					last;
				}

				# Move the block here
				for (my $j = 0; $j < $len; $j++) {
					$blocks[$gap_start + $j] = $blocks[$from + $j];
					$blocks[$from + $j] = -1;
				}
				last;
			}
		}
	}

	for (my $i = 0; $i < @blocks; $i++) {
		$p02 += $i * $blocks[$i] if $blocks[$i] > 0;
	}
}

while (<$input>) {
	chomp;
	my @chrs = split '';

	# Fill up the block list
	my @blocks;
	my $toggle = 1;
	my $block_id = 0;
	for my ($c) (@chrs) {
		if ($toggle) {
			# file ID
			for (my $i = 0; $i < $c; $i++) {
				push(@blocks, $block_id);
			}
			$block_id++;
		} else {
			# empty space
			for (my $i = 0; $i < $c; $i++) {
				push(@blocks, -1);
			}
		}
		$toggle = not $toggle;
	}

	do_p01 @blocks;
	do_p02 @blocks;
}

say "p01: $p01";
say "p02: $p02";
