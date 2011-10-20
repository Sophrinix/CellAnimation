function output_args=gaussianPyramid(input_args)
%simple wrapper module for the Matlab impyramid function
%Input Structure Members
%Image - The image to be processed.
%Output Structure Members
%Image - The filtered image.
output_args.Image=impyramid(input_args.Image.Value,'reduce');

%end gaussianPyramid
end