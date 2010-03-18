function output_args=reconstructObjects(input_args)

img_and=input_args.GuideImage.Value&input_args.ImageToReconstruct.Value;
output_args.Image=imreconstruct(img_and,input_args.ImageToReconstruct.Value);

%end reconstructObjects
end