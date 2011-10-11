function output_args=mkdir_Wrapper(input_args)
%create the specified directory

mkdir(input_args.DirectoryName.Value);
output_args=[];

end