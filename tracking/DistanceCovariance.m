function distCov = DistanceCovariance(images)
%
%computes the covarianve matrix of the distances (as defined by the 
%function Distance) between objects in adjacent frames which have 
%matching track numbers
%
%INPUTS:
%images         -   array of structs representing an image stack
%                   each struct in the array contains the labels and
%                   a list of objects for an image
%
%OUTPUTS:
%distCov        -   covariance matrix for all of the distance vectors
%                   for the matches
%

    distances = [];       
    count = 0;
    
    for(i=2:size(images,2))
        curImage = images(i).s;
        prevImage = images(i-1).s;
        for(j=1:(size(prevImage)))
            if(prevImage(j).trackNum ~= 0)
                curIndx = [curImage(:).trackNum] == prevImage(j).trackNum;                                
                if(~isempty(find(curIndx,1)))
                    distances = [distances; Distance(prevImage(j), curImage(find(curIndx,1)))];
                    count = count + 1;
                end
            end
        end
    end        
    
    distCov = cov(distances);
   
end


