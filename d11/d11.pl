#!/usr/bin/env perl

# I'm writing today's solution on an older machine today.
#use Modern::Perl;
use v5.28;

open(my $input, "<", "input.txt");
#open(my $input, "<", "sample.txt");

my $p01 = 0;
my $p02 = 0;


my @seq;
while (<$input>) {
	@seq = split ' ';
}

# yay its L-systems today!

# Here's the simulation implementation. Note we don't use this code, it's
# here for demonstration only.
sub simulate_p01 {
	for (my $i = 0; $i < 25; $i++) {
		@seq = map {
			if ($_ == 0) {
				1
			} else {
				my $len = length($_);
				if ($len % 2 == 0) {
					my $half = $len >> 1;
					my $l = substr $_, 0, $half;
					my $r = substr $_, $half;

					# need to cast to numbers (trim leading zeroes)
					(int($l), int($r))
				} else {
					$_ * 2024
				}
			}
		} @seq;
	}

	$p01 = @seq;
}

# The simulation won't scale up to 75 rounds. Thing is, L-systems are
# self-similar. You can remember what the increase in size will be.
#
# We had a similar problem the year that we decided to do this in z80 assembly
# actually, something to do with chemical reactions there. DAY14 i think.
#
# Unlike in that case, we are not going to smartly derive an actual
# mathematical formula. But we are going to take advantage of a couple things:
# 1. We don't need the whole sequence in memory at any time. As we calculate
#    the length, we can discard the actual sequence.
# 2. We will see some numbers show up at certain depths multiple times, and
#    we don't need to duplicate work for them.
#
# This will give us something that runs in *reasonable* time/space, but it
# will not be as snazzy as a pure mathematical solution.

# So here we have just the code to expand a single token
sub expand {
	my ( $tok ) = @_;

	my @result;
	if ($tok == 0) {
		@result = ( 1 );
	} else {
		my $len = length($tok);
		if ($len % 2 == 0) {
			my $half = $len >> 1;
			my $l = substr $tok, 0, $half;
			my $r = substr $tok, $half;

			# need to cast to numbers (trim leading zeroes)
			@result = ( int($l), int($r) );
		} else {
			@result = ( $tok * 2024 );
		}
	}

	return @result;
}

# Then we have a bank of token costs at a given depth
# Along the way, we'll remember, if you expand a token N times, how
# many tokens will you get out? It will be finite, even if a token is
# recursive, because we are asking the question about a finite depth.
my %bank;

# And then the cost of a token is defined recursively in terms of its
# output tokens
sub cost {
	my ($tok, $depth) = @_;

	# Our base case
	return 1 if $depth == 0;

	# Memoization to avoid duplicating work at a given depth. You could
	# take this out and things would still work, but much slower.
	my $known_cost = $bank{"$tok,$depth"};
	return $known_cost if defined $known_cost;

	# Here's the actual cost calculation.
	my $generated = 0;
	for my $t (expand $tok) {
		$generated += cost($t, $depth - 1);
	}

	# Again, the memoization to avoid duplicate work.
	$bank{"$tok,$depth"} = $generated;

	return $generated;
}

for my $tok (@seq) {
	$p01 += cost($tok, 25);
	$p02 += cost($tok, 75);
}

say "p01: $p01";
say "p02: $p02";
