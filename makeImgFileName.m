function output_args=makeImgFileName(function_args)
%module to build an image file name
file_base=function_args.FileBase.Value;
cur_frame=function_args.CurFrame.Value;
number_fmt=function_args.NumberFmt.Value;
file_ext=function_args.FileExt.Value;
output_args.FileName=[file_base num2str(cur_frame,number_fmt) file_ext];

%end makeImgFileName
end