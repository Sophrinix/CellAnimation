function output_args=imadjust_Wrapper(input_args)
%basic wrapper for the matlab imadjust function

output_args.Image=imadjust(input_args.Image.Value);

%end imadjust_Wrapper
end