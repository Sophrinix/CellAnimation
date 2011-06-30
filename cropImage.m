function output_args=cropImage(input_args)

img=input_args.Image.Value;
xy_offset=input_args.XYOffset.Value;
crop_size=input_args.CropSize.Value;
output_args.Image=img(xy_offset(2):(xy_offset(2)+crop_size(2)),xy_offset(1):(xy_offset(1)+crop_size(1)));
    
%end cropImageWithOffset
end
