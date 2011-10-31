directory		= '~/Work/Images';
wellName		= 'Well F05';
imageNameBase 	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 0;
endIndex		= 25;
frameStep		= 4;

mkdir([directory filesep wellName filesep 'output']);

%export each object set as a csv file for interfacing with R
for(imNum=startIndex:endIndex)
	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * framestep)

	[im, objSet.wellName, objSet.imageName] = ...
		LoadImage([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);

	[objSet.props, objSet.labels] = NaiveSegment(im);

	SetToCSV(objSet, [	directory filesep ...
						wellName filesep ...
						'output' filesep ...
						imageNameBase imNumStr '.csv']);

	save([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	clear objSet;
	clear imNumStr;
	clear im;
end
