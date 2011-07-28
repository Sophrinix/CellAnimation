objSet = CSVToSet('testrun.mat');
objSet = ResegmentImageStack(objSet, '~/Desktop');
SetToCSV(objSet, 'testrun.csv');
save('testrun.mat', 'objSet');
exit;
