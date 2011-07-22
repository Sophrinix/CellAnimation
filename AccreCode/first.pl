#!/usr/bin/perl
#inputs: list of well ids

use strict;

 
my @ids = @ARGV;

my @args;
my $id;

my $email = "shawn.garbett\@vanderbilt.edu";
my $walltime = "3:00:00";
my $mem = "1gb";
my $output;
my $command;
my $mFile;

print "Enter Userid:";
$userid = <>;
print "Enter Password:";
$passwd = <>;

foreach $id (@ids){
  chomp($id);
  $command = "$id";  
  @args = ($email, $walltime, $mem, $command);
  system("perl createScript.pl $userid $passwd @args");
  system("qsub job$id.pbs");  
}
close MYDATA; 
