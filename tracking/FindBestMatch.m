function [trackNum, maxLklhd] = FindBestMatch(obj, ...
                                              prevImage, ...
                                              distanceMean, ...
                                              distanceCov, ...
                                              N)
%
%computes the likelihood and track number of the best possible match
%between one object and all of the nuclei in the previous frame
%
%INPUTS:
%obj            -   the object to be matched
%
%prevImage      -   array of objects from the previous frame
%
%distanceMean   -   the mean vector of the distances between matches 
%                   in a training set, output from function:
%                   DistanceMean
%
%distanceCov    -   the covariance matrix of the distances between
%                   matches in a training set, output from function:
%                   DistanceCovariance
%
%N              -   degrees of freedom: the number of elements in
%                   the feature vector????
%
%OUTPUTS:
%trackNum       -   the track number (id) of the best match
%
%maLklhd        -   the likelihood that the best match is a true 
%                   match
%

    trackNum = 0;
    maxLklhd = 0;
    
    %relevant objects in previous image
    prevNuclei = find([prevImage(:).nucleus]);
    for(i=1:size(prevNuclei,2))

        %compute distance and likelihood of match
        distance = Distance(obj, prevImage(prevNuclei(i)));
        lklhd = LikelihoodOfMatch(distance, distanceMean,...
                                  distanceCov, N);

        %check likelihood against previous best match
        if(lklhd > maxLklhd)
            maxLklhd = lklhd;
            trackNum = prevImage(prevNuclei(i)).trackNum;
        end	

    end
    
    if(maxLklhd == 0)
        trackNum = 0;
    end        
end