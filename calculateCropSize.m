function output_args=calculateCropSize(input_args)
%module to calculate how much a image will need to be cropped to remove the
%microscope stage offsets

img=input_args.Image.Value;
img_sz=size(img);
xy_offsets=input_args.XYOffsets.Value;
max_offsets=2*(max(abs(xy_offsets))+1);
output_args.CropSize=img_sz-[max_offsets(2) max_offsets(1)];

%end calculateCropRectangle
end