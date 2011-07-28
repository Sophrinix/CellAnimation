function SetToCSV(directory, wellName, imageNameBase, digitsForEnum, ...
				  startIndex, endIndex, filename)

  addpath(pwd);
  cd(directory);
  cd(wellName);
  cd('output');

  fileID = fopen(filename, 'w');

  attribs =  {'Area', 			'MajorAxisLength', 	'MinorAxisLength',	...
			  'Eccentricity',	'ConvexArea', 		'FilledArea', 	  	...
			  'EulerNumber', 	'EquivDiameter', 	'Solidity', 	  	...
			  'Perimeter', 		'Intensity'};

  classifs = {'edge', 			'debris', 			'nucleus', 			...
			  'over', 			'under', 			'predivision', 		...
			  'postdivision', 	'apoptotic', 		'newborn'};

  fprintf(fileID, '%s, %s, %s, %s', 'Well', 'Image', 'X', 'Y');
  for(nameIdx = 1:size(attribs,2))
	fprintf(fileID, ', %s', attribs{1, nameIdx});
  end
  for(nameIdx = 1:size(classifs,2))
	fprintf(fileID, ', %s', classifs{1, nameIdx});
  end

  fprintf(fileID, '\n');

  for(imIdx = startIndex:endIndex)	
    imNumStr = int2str(10^(digitsForEnum-1) + imIdx);
    imNumStr(1) = '0'
    load([imageNameBase imNumStr '.mat']);

    for(objIdx = 1:size(objSet(imIdx).props, 1))
	  fprintf(fileID, '%s, %s, %d, %d',					... 
			  objSet(imIdx).wellName, 					...
			  objSet(imIdx).imageName, 					...
			  objSet(imIdx).props(objIdx).Centroid(1), 	...
			  objSet(imIdx).props(objIdx).Centroid(2));
	  for(propIdx = 1:size(attribs,2))
		fprintf(fileID, ', %d', ...
		  objSet(imIdx).props(objIdx).(attribs{1,propIdx}));
	  end
	  for(propIdx = 1:size(classifs,2))
		fprintf(fileID,', %d', ...
		  objSet(imIdx).props(objIdx).(classifs{1,propIdx}));
	  end
	  fprintf(fileID, '\n');
    end
  end

  fclose(fileID);

end
