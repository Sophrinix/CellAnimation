function output_args=imadjust_Wrapper(input_args)
%basic wrapper for the matlab imadjust function
%Input Structure Members
%Image - The grayscale image to be processed.
%Output Structure Members
%Image - The filtered image.

output_args.Image=imadjust(input_args.Image.Value);

%end imadjust_Wrapper
end