function output_args=distanceWatershed(input_args)
%module to compute the distance watershed of a binary image
img_neg=~input_args.Image.Value;
img_dist=bwdist(img_neg);
img_dist=-img_dist;
img_dist(img_neg)=-Inf;
med_filt_nhood=input_args.MedianFilterNhood.Value;
output_args.WatershedLabel=watershed(medfilt2(img_dist,[med_filt_nhood med_filt_nhood]));

end