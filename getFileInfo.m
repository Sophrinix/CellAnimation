function output_args=getFileInfo(input_args)
%Usage
%This module is used to extract the file name, extension and directory from the absolute path.
%
%Input Structure Members
%DirSep – Directory separator (“\” for Windows, “/” for Linux/Unix).
%PathName – Absolute path name from which file name, extension and directory will be
%extracted.
%
%Output Structure Members
%DirName – The extracted directory name.
%FileName – The extracted file name.
%ExtName – The extracted extension name.
%
%Example
%
%get_file_function.InstanceName='GetFileInfo';
%get_file_function.FunctionHandle=@getFileInfo;
%get_file_function.FunctionArgs.DirSep.Value='\';
%get_file_function.FunctionArgs.PathName.Value=path_name;
%functions_list=addToFunctionChain(functions_list,get_file_function);
%
%…
%
%make_spreadsheet_file_name_function.FunctionArgs.DirName.FunctionInstance='Ge
%tFileInfo';
%make_spreadsheet_file_name_function.FunctionArgs.DirName.OutputArg='DirName';

ds=input_args.DirSep.Value;
path_name=input_args.PathName.Value;
dir_idx=strfind(path_name,ds);
dir_idx=dir_idx(end);
ext_idx=strfind(path_name,'.');
ext_idx=ext_idx(end);

output_args.DirName=path_name(1:dir_idx);
output_args.FileName=path_name((dir_idx+1):(ext_idx-1));
output_args.ExtName=path_name(ext_idx:end);

%end getFileInfo
end
