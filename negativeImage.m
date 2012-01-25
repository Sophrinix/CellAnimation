function output_args=negativeImage(input_args)
% Usage
% This module returns the negative of the image provided as an argument.
% Input Structure Members
% Image – Image to be processed.
% Output Structure Members
% Image – Negative image.

output_args.Image=~input_args.Image.Value;

end
