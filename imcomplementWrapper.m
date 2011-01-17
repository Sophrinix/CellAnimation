function output_args=imcomplementWrapper(input_args)
%simple module to wrap the Matlab imcomplement function

output_args.Image=imcomplement(input_args.Image.Value);

%end saveCellsLabel
end