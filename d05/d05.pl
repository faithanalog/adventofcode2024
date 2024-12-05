#!/usr/bin/env perl

use v5.38;

open(my $input, "<", "input.txt");

my $p01 = 0;
my $p02 = 0;

# key comes before all the values
my %rules_fw;

# key comes after all the values
my %rules_bk;

sub sort_pages {
	my @pages = @_;

	sort {
		# list of everything that comes after the page on the right
		my @comes_after = @{$rules_fw{$b}};

		# if the page on the left should come after the page on the right,
		# then it is greater
		if (grep { $_ == $a } @comes_after) {
			return 1;
		}

		# and the other way around
		my @comes_before = @{$rules_bk{$b}};

		# if the page on the left should come before the page on the right,
		# then it is lesser
		if (grep { $_ == $a } @comes_before) {
			return -1;
		}

		return 0;
	} @pages;
}

sub midpage {
	use integer;
	my @pages = @_;

	my $count = @pages;
	my $midpoint = $count / 2;
	return $pages[$midpoint]
}

while (<$input>) {
	chomp;
	if (my ($k, $v) = /(\d+)\|(\d+)/) {
		$rules_fw{$k} = [] unless $rules_fw{$k};
		push(@{$rules_fw{$k}}, $v);
		$rules_bk{$v} = [] unless $rules_bk{$v};
		push(@{$rules_bk{$v}}, $k);
	} elsif (/,/) {
		my @pages = split ',';
		my @sorted = sort_pages @pages;
		if ("@sorted" eq "@pages") {
			$p01 += midpage @sorted;
		} else {
			$p02 += midpage @sorted;
		}
	}
}

say "p01: $p01";
say "p02: $p02";
