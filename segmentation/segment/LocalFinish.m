directory		= '~/Work/Images/2009-05-01_001';
wellName		= 'WellB02';
imageNameBase 	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 290;
endIndex		= 300;
frameStep		= 1;
outdir 			= 'WellB02/naive';

for(imNum=startIndex:endIndex)
	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	%load the current objSet
	load([	directory filesep ...
			outdir filesep ...
			imageNameBase imNumStr '.mat']);

	%load and add classification data from R into matlab object
	objSet = CSVToSet(objSet, [directory filesep outdir]);
  
	%save the updated objSet
	save([	directory filesep ...
			outdir filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');
  
	%reclaim memory
	clear objSet;
	clear imNumStr;	
end
