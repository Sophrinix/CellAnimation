loadim
images = NaiveTrack(images);
%trainingImages = images(1:3);
%h = TrackingReview(1, 'image', trainingImages);
%uiwait(h);
%load('trainingset.mat')
dMean = DistanceMean(images);
dCov = DistanceCovariance(images);
N = 6;
loadim
[images, tm] = TrackImages(images, dMean, dCov, N);
