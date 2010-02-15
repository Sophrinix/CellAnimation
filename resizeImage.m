function output_args=resizeImage(input_args)

output_args.Image=imresize(input_args.Image.Value,input_args.Scale.Value,input_args.Method.Value);

%end resizeImage
end