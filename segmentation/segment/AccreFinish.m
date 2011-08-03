directory		= getenv('DIRECTORY');
wellName		= getenv('WELLNAME');
imageNameBase 	= getenv('IMAGENAMEBASE');
fileExt			= getenv('FILEEXT');
digitsForEnum	= str2num(getenv('DIGITSFORENUM'));
startIndex		= str2num(getenv('STARTINDEX'));
endIndex		= str2num(getenv('ENDINDEX'));

for(i=startIndex:endIndex)
  imNumStr = int2str(10^(digitsForEnum-1)+i);
  imNumStr(1) = '0';

  %load the current objSet
  load([directory filesep wellName filesep 'output' filesep ...
	    imageNameBase imNumStr '.mat']);

  %load and add classification data from R into matlab object
  objSet = CSVToSet(objSet, [directory filesep wellName filesep 'output']);

  %remove temporary csv files (communication between R and matlab)
  
  %save the updated objSet
  save([directory filesep wellName filesep 'output' filesep ...
		imageNameBase imNumStr '.mat'], 'objSet');
  
  %reclaim memory
  clear objSet;
end

exit;
