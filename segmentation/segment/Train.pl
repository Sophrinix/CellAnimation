#!/usr/bin/perl

use strict;

my @classifications = ("debris", "nucleus", "over", "under", "predivision", "postdivision", "apoptotic", "newborn");

my $name;
foreach $name (@classifications)
{
  system("R --vanilla --slave --args '$ARGV[0]' '$ARGV[1]' '$name' 'model$name.Rdata' < CreateModel.R\n");
}
