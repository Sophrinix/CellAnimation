function output_args=gaussianPyramid(input_args)
%simple wrapper module for the Matlab impyramid function
output_args.Image=impyramid(input_args.Image.Value,'reduce');

%end gaussianPyramid
end