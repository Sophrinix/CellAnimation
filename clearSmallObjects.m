function output_args=clearSmallObjects(input_args)
%simple wrapper module for bwareaopen MATLAB function

output_args.Image=bwareaopen(input_args.Image.Value,input_args.MinObjectArea.Value);

%end clearSmallObjects
end
