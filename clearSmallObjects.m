function output_args=clearSmallObjects(input_args)

output_args.Image=bwareaopen(input_args.Image.Value,input_args.MinObjectArea.Value);

%end clearSmallObjects
end