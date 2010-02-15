function output_args=reconstructObjects(input_args)

output_args.Image=imreconstruct(input_args.GuideImage.Value,input_args.ImageToReconstruct.Value);

%end reconstructObjects
end