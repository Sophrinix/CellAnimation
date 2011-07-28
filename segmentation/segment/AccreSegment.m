objSet = SegmentImageStack(1, 20, '~/Desktop', 'WellD10', 'DsRed - Confocal - n', '.tif', 6);
SetToCSV(objSet, 'testrun.csv');
save('testrun.mat', 'objSet');
exit;
