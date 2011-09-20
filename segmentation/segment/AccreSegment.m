directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase 	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));

%segments the images as described above and saves each segmentation as an
%object set in directory/wellName/output
SegmentImageStack(directory, wellName, imageNameBase, fileExt, ...
				  digitsForEnum, startIndex, endIndex);

%export each object set as a csv file for interfacing with R
for(i=startIndex:endIndex)

  imNumStr = sprintf('%%0%dd', digitsForEnum);
  imNumStr = sprintf(imNumStr, imNum);

  load([directory filesep wellName filesep 'output' filesep ...
		imageNameBase imNumStr '.mat']);

  SetToCSV(objSet, [directory filesep wellName filesep 'output' filesep ...
 				    imageNameBase imNumStr '.csv']);
  clear objSet;
end

exit;
