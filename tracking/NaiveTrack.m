function trackedImages = NaiveTrack(images)
%
%matches nuclei in one frame with nuclei in the previous frame (1 
%to 1), based entirely on distance, and only if that match is 
%closer than some preset distance
%
%INPUTS:
%images         -   array of structs representing an image stack 
%                   Each struct in the array contains the labels and 
%                   a list of objects for an image
%
%OUTPUTS:
%trackedImages  -   an array similar to the input, but with track 
%                   numbers assigned to all objects (non-nuclei are
%                   asssigned track number 0)
%

    trackedImages = images;
    curImage = trackedImages(1).s;
    trackCounter = 1;
    for(i=1:size(curImage))        
        if(curImage(i).nucleus)
            curImage(i).trackNum = trackCounter;
            trackCounter = trackCounter + 1;
        else
            curImage(i).trackNum = 0;
        end
    end
    trackedImages(1).s = curImage;

    for(i=2:size(trackedImages,2))%through the list of images
        
        curImage = trackedImages(i).s;
        prevImage = trackedImages(i-1).s;
        
        for(j=1:size(curImage))%through the list of objects in the current image
            
            minDist = sqrt(10^2 + 10^2);
            match = 0;
            if(curImage(j).nucleus)
                for(k=1:size(prevImage))
                    
                    prevCentroid = prevImage(k).Centroid;                 
                    curCentroid = curImage(j).Centroid;
                    dist = sqrt((curCentroid(1) - prevCentroid(1))^2 + ...
                                (curCentroid(2) - prevCentroid(2))^2);                   
                    if(dist < minDist)                        
                        minDist = dist;
                        match = 1;
                        curImage(j).trackNum = prevImage(k).trackNum;                       
                    end
                end
                
                if(match == 0)
                    curImage(j).trackNum = trackCounter;
                    trackCounter = trackCounter + 1;                 
                end
                
            else
                curImage(j).trackNum = 0;
            end
            
        end
        
        trackedImages(i).s = curImage;
                
    end

end