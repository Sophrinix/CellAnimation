function output_args=concatenateText(input_args)
%module to concatenate all the variables provided in input_args. all the variables
%have to be text
output_text=[];
var_names=fieldnames(input_args);
for i=1:length(var_names)
    output_text=[output_text input_args.(var_names{i}).Value];
end
output_args.Text=output_text;

%end concatenateText
end