%AccreFinish.m
%imports data from csv files in directory/outdir into 
%corresponding matlab objects

directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase 	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));
frameStep		= str2num(getenv('FRAMESTEP'));
outdir			= getenv('OUTDIR');

mkdir([directory filesep wellName filesep 'gmm']);

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
			wellName filesep ...
			'gmm' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');
  
	%reclaim memory
	clear objSet;
	clear imNumStr;
end

exit;
