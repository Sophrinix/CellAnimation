function output_args=cropImage(input_args)
% cropImage
% Usage
% This module is used to crop an image from a point specified from the (0,0) coordinate to the specified size.
% Input Structure Members
% CropSize – Two number vector containing the desired dimensions for the cropped image.
% Image – The image to be processed.
% XYOffset – Offset point (from the (0,0) coordinate) from which the image should be cropped.
% Output Structure Members
% Image – Cropped image.

img=input_args.Image.Value;
xy_offset=input_args.XYOffset.Value;
crop_size=input_args.CropSize.Value;
output_args.Image=img(xy_offset(2):(xy_offset(2)+crop_size(2)),xy_offset(1):(xy_offset(1)+crop_size(1)));
    
%end cropImageWithOffset
end
