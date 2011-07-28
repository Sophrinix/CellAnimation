function output_args=concatenateText(input_args)
%Usage
%This module is used to concatenate all the variables provided in the input structure. All the
%variables need to be strings.
%
%Input Structure Members
%Any name and any number of text variables may be used in the input structure.
%
%Output Structure Members
%Text – The string resulting from the concatenation of all the input arguments.
%
%Example
%
%make_label_file_name_function.InstanceName='MakeLabelFileName';
%make_label_file_name_function.FunctionHandle=@concatenateText;
%make_label_file_name_function.FunctionArgs.DirName.FunctionInstance='GetFileI
%nfo';
%make_label_file_name_function.FunctionArgs.DirName.OutputArg='DirName';
%make_label_file_name_function.FunctionArgs.FileName.FunctionInstance='GetFile
%Info';
%make_label_file_name_function.FunctionArgs.FileName.OutputArg='FileName';
%make_label_file_name_function.FunctionArgs.FileExt.Value='.mat';
%functions_list=addToFunctionChain(functions_list,make_label_file_name_functio
%n);
%
%…
%
%save_label_function.FunctionArgs.FileName.FunctionInstance='MakeLabelFileName
%';
%save_label_function.FunctionArgs.FileName.OutputArg='Text';

output_text=[];
var_names=fieldnames(input_args);
for i=1:length(var_names)
    output_text=[output_text input_args.(var_names{i}).Value];
end
output_args.Text=output_text;

%end concatenateText
end
