function output_args=imclearborder_Wrapper(input_args)
%a very simple wrapper module for the Matlab imclearborder function
%Input Structure Members
%Image - The binary image to be processed.
%Output Structure Members
%Image - The resulting binary image.

output_args.Image=imclearborder(input_args.Image.Value);

end