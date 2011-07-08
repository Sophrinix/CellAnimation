function distVec = Distance(obj1, obj2)
%
%computes the distance between two objects based on the categories
%in the feature vector
%
%INPUTS:
%obj1           -   first object (order does not matter)
%
%obj2           -   second object
%
%OUTPUTS:
%distVec        -   vector of distances between the objects for
%                   each element in the feature vector
%

    distVec = abs(FeatureVector(obj1) - FeatureVector(obj2));

end