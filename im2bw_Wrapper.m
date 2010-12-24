function output_args=im2bw_Wrapper(input_args)
%a very simple wrapper module for the Matlab im2bw function

output_args.Image=im2bw(input_args.Image.Value);

end