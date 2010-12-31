function output_args=negativeImage(input_args)
%negative image module
%return the negative of the image provided in Image
output_args.Image=~input_args.Image.Value;

end