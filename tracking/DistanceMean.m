function distMeanVec = DistanceMean(images)
%
%computes the mean of distances (as defined by the function Distance)
%between objects in adjacent frames which have matching track numbers
%
%INPUTS:
%images         -   array of structs representing an image stack 
%                   Each struct in the array contains the labels and 
%                   a list of objects for an image
%
%OUTPUTS:
%distMeanVec    -   vector of the means of the distances of each 
%                   element in the feature vector
%

    curImage = images(1).s;
    distSum = zeros(size(FeatureVector(curImage(1))));
    numMatches = 0;
    
    for(i=2:size(images,2))
        curImage = images(i).s;
        prevImage = images(i-1).s;
        for(j=1:(size(prevImage)))            
            if(prevImage(j).trackNum ~= 0)
                curIndx = [curImage(:).trackNum] == prevImage(j).trackNum;
                if(~isempty(find(curIndx)))
                    distSum = distSum + Distance(curImage(find(curIndx)), prevImage(j));
                    numMatches = numMatches + 1;
                end
            end
        end
    end
    
    distMeanVec = distSum / numMatches;

end