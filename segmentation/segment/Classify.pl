#!/usr/bin/perl

use strict;

my @classifications = ("debris", "nucleus", "over", "under", "predivsion", "postdivision", "apoptotic", "newborn");

my $name;
foreach $name (@classifications)
{
  print("R --vanilla --slave --args '$ARGV[0]' '$ARGV[1]' '$name' < PredictImage.R\n");
}
