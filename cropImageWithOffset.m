function output_args=cropImageWithOffset(input_args)

img=input_args.Image.Value;
xy_offset=input_args.XYOffset.Value;
crop_size=input_args.CropSize.Value;
img_sz=size(img);
center_pixel=floor((img_sz+1)/2);
x_low=center_pixel(1)-round(crop_size(1)/2)+xy_offset(2);
x_high=x_low+crop_size(1)-1;
y_low=center_pixel(2)-round(crop_size(2)/2)+xy_offset(1);
y_high=y_low+crop_size(2)-1;
output_args.Image=img(x_low:x_high,y_low:y_high);
    
%end cropImageWithOffset
end
