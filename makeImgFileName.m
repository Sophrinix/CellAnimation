function output_args=makeImgFileName(input_args)
%Usage
%This module is used to build the filename of a frame from a time-lapse movie using the root file
%name, current frame number and a specified number format and file extension.
%
%Input Structure Members
%CurFrame – The index of the current frame.
%FileBase – The root of the image file name.
%FileExt – The file extension.
%NumberFmt – The number format to be used. See MATLAB sprintf documentation for format
%documentation.
%
%Output Structure Members
%FileName – String containing the resulting file name.
%
%Example
%
%make_file_name_function.InstanceName='MakeImageNamesInSegmentationLoop';
%make_file_name_function.FunctionHandle=@makeImgFileName;
%make_file_name_function.FunctionArgs.FileBase.Value=TrackStruct.ImageFileBase
%;
%make_file_name_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationL
%oop';
%make_file_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
%make_file_name_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat
%;
%make_file_name_function.FunctionArgs.FileExt.Value=TrackStruct.ImgExt;
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,make_f
%ile_name_function);
%
%…
%
%read_image_function.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesIn
%SegmentationLoop';
%read_image_function.FunctionArgs.ImageName.OutputArg='FileName';

file_base=input_args.FileBase.Value;
cur_frame=input_args.CurFrame.Value;
number_fmt=input_args.NumberFmt.Value;
file_ext=input_args.FileExt.Value;
output_args.FileName=[file_base num2str(cur_frame,number_fmt) file_ext];

%end makeImgFileName
end
