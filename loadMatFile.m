function output_args=loadMatFile(input_args)
%module to load all the variables in a Matlab .mat file
mat_file_name=input_args.MatFileName.Value;
vars_info = whos('-file', mat_file_name); 
load_struct=load(mat_file_name);
for i=1:length(vars_info)
    var_name=vars_info(i).name;
    output_args.(var_name)=load_struct.(var_name);
end

end