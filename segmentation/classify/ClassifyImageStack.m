function ClassifyImageStack(path, imFileBase, digitsForEnum, startIndex, ...
                            endIndex, outputFolder, classifier)
    
  disp('Classifying Images');
  for(imNum=startIndex:endIndex)                    
    disp(imNum);
        
    %create end of file name
    imNumStr = int2str(imNum);
    while(length(imNumStr) < digitsForEnum)
      imNumStr = ['0' imNumStr]; 
    end
        
    load([path '/' imFileBase imNumStr '.mat'], 's', 'l');
       
    classification_names = {'debris', 'nucleus', 'over', 'under', ...
							'premitotic', 'postmitotic' 'apoptotic'};
    for i=1:size(classification_names,2)
      s = NaiveClassify(classification_names{1,i}, s,...
                        classifier.(classification_names{1,i}));
    end

    %save output to file
    save([outputFolder '/' imFileBase imNumStr '.mat'], 's', 'l');      
  end
                        
end
