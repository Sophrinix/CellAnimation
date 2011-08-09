directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase 	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));

%resegment the images described above and saves the updated segmentation
%as an object set in directory/wellName/output
ResegmentImageStack(directory, wellName, imageNameBase, fileExt, ...
					digitsForEnum, startIndex, endIndex);

%export each objSet as a CSV file to interfacing with R
for(i=startIndex:endIndex)
  imNumStr = int2str(10^(digitsForEnum-1)+i);
  imNumStr(1) = '0';

  load([directory filesep wellName filesep 'output' filesep ...
		imageNameBase imNumStr '.mat']);

  SetToCSV(objSet, [directory filesep wellName filesep 'output' filesep ...
 				    imageNameBase imNumStr '.csv']);
  clear objSet;
end

exit;
