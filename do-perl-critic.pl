#!/usr/bin/env perl

use 5.010;

use warnings;
use strict;

use Perl::Critic;

my $perl_file = shift @ARGV;

die "Usage: $0 file.pl" unless defined $perl_file;

my $violation_score = 0;

for my $severity ( 1 .. 5 ) {
    my $critic = Perl::Critic->new( -severity => $severity );
    $violation_score += scalar( $critic->critique($perl_file) );
}

say "Violation score: $violation_score";

exit;
