function [newImage, trackCount] = AssignArbitraryTrackNumbers(image)

    newImage = image;
    trackCount = 0;
    
    for(obj=1:size(newImage,1))
        if(newImage(obj).nucleus)
            newImage(obj).trackNum = trackCount + 1;
            trackCount = trackCount + 1;
        else
            newImage(obj).trackNum = 0;
        end
    end

end