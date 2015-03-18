#!/usr/bin/perl
#

use strict;
use warnings;

my $function;
my $output = undef;

while (<>)
{
	if (/^Function (\w+)/)
	{
		$function = $1;
		unless (open($output, ">$function.dot")) {
			warn "Couldn't open output file for $function";
			$output = undef;
		}
	}
	elsif (/digraph d/ ... /^\}$/)
	{
		print $output $_ if $output;
	}
	else
	{
		close $output if $output;
		$output = undef;
	}
}
0;
