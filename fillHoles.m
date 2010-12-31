function output_args=fillHoles(input_args)
%module to fill holes in objects in a binary image
output_args.Image=imfill(input_args.Image.Value,'holes');

%end fillHoles
end