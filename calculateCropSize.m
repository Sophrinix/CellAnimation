function output_args=calculateCropSize(input_args)
%This module is used to calculate how much a image will need to be cropped to remove the
%microscope stage offsets
%Input Structure Members
%Image - Image in the sequence to be cropped.
%XYOffsets - Array containing the offsets for all the images in the series.
%Output Structure Members
%CropSize - Array indicating how much the image will need to be cropped in
%each direction.

img=input_args.Image.Value;
img_sz=size(img);
xy_offsets=input_args.XYOffsets.Value;
max_offsets=2*(max(abs(xy_offsets))+1);
output_args.CropSize=img_sz-[max_offsets(2) max_offsets(1)];

%end calculateCropRectangle
end