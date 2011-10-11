function output_args=imclearborder_Wrapper(input_args)
%a very simple wrapper module for the Matlab imclearborder function

output_args.Image=imclearborder(input_args.Image.Value);

end