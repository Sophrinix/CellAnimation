function output_args=getFileInfo(input_args)
%module to extract the file name, extension and directory from the absolute path
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