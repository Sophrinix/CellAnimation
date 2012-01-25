function output_args=reconstructObjects(input_args)
%simple wrapper to MATLAB imreconstruct function
%Input Structure Members
%GuideImage - Guide image for the reconstruction.
%ImageToReconstruct - The image to reconstruct.
%Output Structure Members
%Image - The resulting image.
img_and=input_args.GuideImage.Value&input_args.ImageToReconstruct.Value;
output_args.Image=imreconstruct(img_and,input_args.ImageToReconstruct.Value);

%end reconstructObjects
end