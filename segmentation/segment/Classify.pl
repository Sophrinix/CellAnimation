#!/usr/bin/perl
#inputs:
#	0 - directory
#	1 - imageNameBase
#	2 - startIndex
#	3 - endIndex
#	4 - digitsForEnum

print("$ARGV[1]");

use strict;

my @classifications = ("debris", "nucleus", "under", "predivision", "postdivision", "newborn");

my $name;
my $image;
my $imNumStr;

foreach $name (@classifications)
{
  for($image = $ARGV[2]; $image <= $ARGV[3]; $image++)
  {
    $imNumStr = sprintf("%0$ARGV[4]d", $image);
    system("~/R-2.13.0/bin/R --vanilla --slave --args " .
#    system("R --vanilla --slave --args " . 
					  "'$ARGV[0]' " . 
				      "'$ARGV[1]$imNumStr' " .
				      "'$name' " . 
		   		      "< PredictImage.R\n");
  }
}
