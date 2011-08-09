function likelihood = LikelihoodOfMatch(dist, distMean, distCov, N)
%
%computes the likelihood that two objects seperated by the given 
%distance are a match (the same object in two consecutice frames)
%
%INPUTS:
%dist           -   the distance between the feature vectors of the
%                   two objects, output from function: Distance
%
%distMean       -   the mean vector of the distances between matches
%                   in a training set, output from function:
%                   DistanceMean
%
%distCov        -   the covariance matrix of the distances between
%                   matches in a training set, output from function:
%                   DistanceCovariance
%
%N              -   degrees of freedom: the number of elements in
%                   the feature vector????
%
%OUTPUTS:
%likelihood     -   the likelihood that the objects in question are
%                   a match
%

    %likelihood = 1 / sqrt((2 * pi) ^ N * det(distCov)) * ...
    %    exp(-.5 * (dist - distMean) * (distCov ^ -1) * ...
    %        transpose(dist - distMean));

    %log likelihood
    likelihood = -0.5 * N * log(2 * pi) - 0.5 * log(det(distCov)) - 0.5 * ...
            ((dist - distMean) * (distCov ^ -1) * ...
            transpose(dist - distMean));
    
end