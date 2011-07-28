#!/usr/bin/perl

use strict;

my @classifications = ("debris", "nucleus", "under", "predivision", "postdivision", "newborn");

my $name;
foreach $name (@classifications)
{
  system("R --vanilla --slave --args '$ARGV[0]' '$ARGV[1]' '$name' < PredictImage.R\n");
}
