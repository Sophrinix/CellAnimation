function output_args=distanceWatershed(input_args)
% Usage
% This module is used to compute the distance watershed of a binary image.
% Input Structure Members
% Image � The binary image for which the distance watershed will be computed.
% MedianFilterNhood � The size of the median filter which will be used to smooth the watershed.
% Output Structure Members
% LabelMatrix � The result of the distance watershed.

img_neg=~input_args.Image.Value;
img_dist=bwdist(img_neg);
img_dist=-img_dist;
img_dist(img_neg)=-Inf;
med_filt_nhood=input_args.MedianFilterNhood.Value;
output_args.LabelMatrix=watershed(medfilt2(img_dist,[med_filt_nhood med_filt_nhood]));

end
