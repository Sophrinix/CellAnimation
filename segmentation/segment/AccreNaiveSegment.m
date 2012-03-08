directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase 	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));
frameStep		= str2num(getenv('FRAMESTEP'));
outdir			= getenv('OUTDIR');

mkdir([directory filesep wellName filesep 'naive']);

%export each object set as a csv file for interfacing with R
for(imNum=startIndex:endIndex)
  
	imNumStr = sprintf('%%0%dd', digitsForEnum);
  	imNumStr = sprintf(imNumStr, imNum * frameStep);
  	
	%load image 
  	[im, objSet.wellName, objSet.imageName] = ...
    	LoadImage([	directory filesep ...
					outdir filesep ...
					imageNameBase imNumStr fileExt]);

	%segment
	[objSet.props, objSet.labels] = NaiveSegment(im);


	SetToCSV(objSet, [	directory filesep ...
						wellName filesep ...
						'naive' filesep ...
						imageNameBase imNumStr '.csv']);

	save([	directory filesep ...
			wellName filesep ...
			'naive' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	clear objSet;
	clear im;
	clear imNumStr;
end

exit;
