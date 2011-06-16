function ResegmentImageStack(imagesPath, propsPath, imFileBase, imFileExt, ...
                             digitsForEnum, startIndex, endIndex, outputFolder)
    disp('Resegmenting Images');
    for(imNum=startIndex:endIndex)                
        
        disp(imNum);
        
        %create end of file name
        imNumStr = int2str(imNum);
        while(length(imNumStr) < digitsForEnum)
            imNumStr = ['0' imNumStr]; 
        end
        
        %load image
        im = imread([imagesPath '/' imFileBase imNumStr imFileExt]);
        
        %load properties and labels
        load([propsPath '/' imFileBase imNumStr '.mat'], 's', 'l');
        
        %find under-segmented objects
        underSegObjs = find([s(:).under])
        [s,l] = Resegment(im, s, l, underSegObjs);
        
        %save output to file
        save([outputFolder '/' imFileBase imNumStr '.mat'], 's', 'l');                      
        
    end
    
    
end