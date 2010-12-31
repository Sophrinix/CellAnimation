function output_args=clearSmallObjects(input_args)
%module to remove objects below a certain area from the image

output_args.Image=bwareaopen(input_args.Image.Value,input_args.MinObjectArea.Value);

%end clearSmallObjects
end