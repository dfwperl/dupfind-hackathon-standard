#!/usr/bin/env perl

use 5.010;

use warnings;
use strict;

use Perl::Critic;

my $perl_file = shift @ARGV;

die "Usage: $0 file.pl" unless defined $perl_file;

my $critic = Perl::Critic->new();

my @violations = $critic->critique( $perl_file );

say for @violations;

say scalar @violations, ' total violations';

exit;
