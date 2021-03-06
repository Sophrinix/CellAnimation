directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase 	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));
frameStep		= str2num(getenv('FRAMESTEP'));

for(imNum=startIndex:endIndex)
	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	load([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat']);

	im = imread([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);

	underSegObjs = find([objSet.props(:).under]);
	[objSet.props, objSet.labels] = ...
		Resegment(im, objSet.props, objSet.labels, underSegObjs);

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
	clear underSegObjs;
end

exit;
