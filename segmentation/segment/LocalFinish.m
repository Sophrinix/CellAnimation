directory		= '~/Work/Images';
wellName		= 'Well F05';
imageNameBase 	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 0;
endIndex		= 25;
frameStep		= 4;

for(imNum=startIndex:endIndex)
	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	%load the current objSet
	load([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat']);

	%load and add classification data from R into matlab object
	objSet = CSVToSet(objSet, [directory filesep wellName filesep 'output']);

	%remove temporary csv files (communication between R and matlab)
  
	%save the updated objSet
	save([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');
  
	%reclaim memory
	clear objSet;
	clear imNumStr;	
end
