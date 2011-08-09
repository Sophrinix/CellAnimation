function featureVec = FeatureVector(obj)
%
%computes the feature vector for an individual object
%
%INPUTS:
%obj            -   the object
%
%OUTPUTS:
%featureVec     -   a vector containing the relevant values
%

    i = 1;
    featureVec(i) = obj.Centroid(1); i = i + 1;
    featureVec(i) = obj.Centroid(2); i = i + 1;
    featureVec(i) = obj.Area; i = i + 1;
    featureVec(i) = obj.Eccentricity; i = i + 1;
    featureVec(i) = obj.MajorAxisLength; i = i + 1;
    %others?
    featureVec(i) = obj.Solidity; i = i + 1;
    featureVec(i) = obj.MinorAxisLength; i = i + 1;
    %???featureVec(i) = obj.Orientation; i = i + 1;
    

end