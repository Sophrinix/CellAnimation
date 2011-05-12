#inputs: list of well ids

use strict;
 
my @ids = @ARGV;

my @args;
my $id;

my $email = "samuel.w.hooke\@vanderbilt.edu";
my $walltime = "3:00:00";
my $mem = "1gb";
my $output;
my $command;
my $mFile;

foreach $id (@ids){
	chomp($id);
	$command = "$id";	
	@args = ($email, $walltime, $mem, $command);
	print("perl createScript.pl @args\n");			
	system("perl createScript.pl @args");
	system("qsub job$id.pbs");	
}
close MYDATA; 
