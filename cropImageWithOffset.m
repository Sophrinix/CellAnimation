function output_args=cropImageWithOffset(input_args)
%Usage
%This module is used to crop an image at a specified point to the specified size.
%
%Input Structure Members
%CropSize – Two number vector containing the desired dimensions for the cropped image.
%Image – The image to be processed.
%XYOffset – Offset point (from the center of the original image) at which the cropped image
%should be centered.
%
%Output Structure Members
%Image – Cropped image.
%
%Example
%
%crop_image.InstanceName='CropImage';
%crop_image.FunctionHandle=@cropImageWithOffset;
%crop_image.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
%crop_image.FunctionArgs.Image.OutputArg='Image';
%crop_image.FunctionArgs.XYOffset.FunctionInstance='GetCurrentOffset';
%crop_image.FunctionArgs.XYOffset.OutputArg='ArrayVal';
%crop_image.FunctionArgs.CropSize.FunctionInstance='IfFirstFrame';
%crop_image.FunctionArgs.CropSize.OutputArg='CropSize';
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,crop_i
%mage);
%
%…
%
%save_image.FunctionArgs.Image.FunctionInstance='CropImage';
%save_image.FunctionArgs.Image.OutputArg='Image';

img=input_args.Image.Value;
xy_offset=input_args.XYOffset.Value;
crop_size=input_args.CropSize.Value;
img_sz=size(img);
center_pixel=floor((img_sz+1)/2);
x_low=center_pixel(1)-round(crop_size(1)/2+xy_offset(2));
x_high=x_low+crop_size(1)-1;
y_low=center_pixel(2)-round(crop_size(2)/2+xy_offset(1));
y_high=y_low+crop_size(2)-1;
output_args.Image=img(x_low:x_high,y_low:y_high);
    
%end cropImageWithOffset
end
