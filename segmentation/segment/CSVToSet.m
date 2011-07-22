function objSet = CSVToSet(objFile)
  
  %load matlab object objSet from the file given
  load(objFile);

  names = {'debris', 		'nucleus', 		'over', 		'under', ...
		   'predivision', 	'postdivision', 'apoptotic', 	'newborn'};

  for(nm=1:size(names,2))
    fileID = fopen([names{1,nm} '.csv']);
    line = fgetl(fileID);
    
    img = 1;
    while(img < size(objSet,2))
      for(obj=1:size(objSet(img).props,1))
        line = fgetl(fileID);
        objSet(img).props(obj).debris = str2num(line(size(line,2)-1));
      end
      img = img + 1;
    end   

    fclose(fileID);
  end

end
