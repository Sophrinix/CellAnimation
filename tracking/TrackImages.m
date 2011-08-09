function [trackedImages, trackVector] = TrackImages(images, ...
                                     distanceMean, ...
                                     distanceCov, ...
                                     N)

%
%tracks objects through a set of images using distance between
%feature vectors and to determine a match based on maximum 
%likelihood
%
%INPUTS:
%images         -   array of structs representing an image stack 
%                   each struct in the array contains the labels and 
%                   a list of objects for an image
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
%trackedImages  -   similar to INPUT images, but each object is 
%                   given a track number (trackNum) and likelihood
%                   (lklhd) calculated by the algorithm
%

    %output images stack - input is unchanged
    trackedImages = images;
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %assign track numbers to cells in first image
    [trackedImages(1).s, trackCount] = ...
        AssignArbitraryTrackNumbers(trackedImages(1).s);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for(index=2:size(images,2))
        disp(index);
        curImage = trackedImages(index).s;
        prevImage = trackedImages(index - 1).s;
        
        %assign 0 as track number for all objects
        for(obj=1:size(curImage,1))
            curImage(obj).trackNum = 0;
        end
        
        lklhdMatrix = LikelihoodMatrix(prevImage, ...
                                       curImage, ...
                                       distanceMean, ...
                                       distanceCov, ...
                                       N);

        %call recursive function to assign tracks
        trackVector = AssignTracks(lklhdMatrix);
        
        %assign track numbers from track matrix produced above
        prevTrackIndex = find([prevImage(:).trackNum]);
        curNucleiIndex = 1:size(curImage,1);%find([curImage(:).nucleus]);
        for(obj=1:size(curNucleiIndex,2))
            if(trackVector(obj))                            
                curImage(curNucleiIndex(obj)).trackNum = ...
                    prevImage(prevTrackIndex(trackVector(obj))).trackNum;
            %else
            %    curImage(curNucleiIndex(obj)).trackNum = 0;%trackCount + 1;
            %    trackCount = trackCount + 1;
            end
        end
        trackedImages(index).s = curImage;
    end
    trackCount
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%