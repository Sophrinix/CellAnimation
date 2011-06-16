function SegmentImageStack(path, imFileBase, imFileExt, digitsForEnum, ...
                           startIndex, endIndex, outputFolder)
    
    disp('Segmenting Images');
    for(imNum=startIndex:endIndex)                
    
        disp(imNum);
        
        %create end of file name
        imNumStr = int2str(imNum);
        while(length(imNumStr) < digitsForEnum)
            imNumStr = ['0' imNumStr]; 
        end

        %load image
        im = imread([path '/' imFileBase imNumStr imFileExt]);

        %segment
        [s,l] = NaiveSegment(im);

        %save output to file
        save([outputFolder '/' imFileBase imNumStr '.mat'], 's', 'l');
        
    end

end