#input: 0: email, 1: walltime, 2: mem, 3: well id#, 4: userid (for omero), 5: password

use strict;

open(MYDATA, ">job$ARGV[3].pbs");

print MYDATA "#!/bin/bash\n";
print MYDATA "#PBS -M $ARGV[0]\n";
print MYDATA "#PBS -l nodes=1:ppn=1:x86\n";
print MYDATA "#PBS -l walltime=$ARGV[1]\n";
print MYDATA "#PBS -l mem=$ARGV[2]\n";
print MYDATA "#PBS -o $ARGV[3].out\n";
print MYDATA "#PBS -j oe\n";
print MYDATA "matlab < ~/CellAnimation/AccreCode/$ARGV[3].m\n";

close MYDATA;

open(MYDATA, ">$ARGV[3].m");

print MYDATA "cd ~/CellAnimation/AccreCode\n";
print MYDATA "TrackNuclei($ARGV[3], $ARGV[4], $ARGV[5]) \;\n";
print MYDATA "exit\n";

close MYDATA;
