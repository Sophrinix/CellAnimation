function output_args=imcomplementWrapper(input_args)
%simple module to wrap the Matlab imcomplement function
%Input Structure Members
%Image - The image to be processed.
%Output Structure Members
%Image - The resulting image.

output_args.Image=imcomplement(input_args.Image.Value);

%end saveCellsLabel
end