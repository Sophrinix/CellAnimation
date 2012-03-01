directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));
frameStep		= str2num(getenv('FRAMESTEP'));
outdir			= getenv('OUTDIR');
training		= getenv('TRAINING');

mkdir([directory filesep wellName filesep 'gmm']);

%load training set
load(training);
trainingSet = objSet;
clear objSet;

for(imNum = startIndex:endIndex)

	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	im = imread([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);

	load([	directory filesep ...
			outdir filesep ...
			imageNameBase imNumStr '.mat']);

	objSet = RemoveObjects(objSet, 'nucleus');
	objSet = RemoveObjects(objSet, 'debris');

	objSet = GMMSegment(im, objSet, trainingSet);

	SetToCSV(objSet, [	directory filesep ...
						wellName filesep ...
						'gmm' filesep ...
						imageNameBase imNumStr '.csv']);

	save([	directory filesep ...
			wellName filesep ...
			'gmm' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	imwrite(objSet.labels, [	directory filesep ...
								wellName filesep ...
								'gmm' filesep ...
								imageNameBase imNumStr '.jpg'], ...
			'jpg');

	clear objSet;
	clear im;
	clear imNumStr;

end

exit

