function []=assayOffsetFrames(file_root,frame_count,frame_offsets,varargin)
%assay to offset and crop frames based on computed microscope stage offsets
%at each frame
%optional arguments 'FrameStep','ImageExtenstion','NumberFormat','StartFrame'
global functions_list;
functions_list=[];

frame_step=1;
img_ext='.tif';
number_fmt='%06d';
start_frame=1;
ds='\';

for i=1:2:size(varargin,2)
    switch varargin{i}        
        case 'FrameStep'
            frame_step=varargin{i+1};
        case 'ImageExtension'
            img_ext=varargin{i+1};
        case 'NumberFormat'
            number_fmt=varargin{i+1};
        case 'StartFrame'
            start_frame=varargin{i+1};
        case 'DirectorySeparator'
            ds=varargin{i+1};
    end
end

dir_idx=find(file_root==ds,1,'last');
output_dir=[file_root(1:dir_idx) 'output' ds 'cropped frames'];
mkdir(output_dir);
output_root=[output_dir ds file_root((dir_idx+1):end)];


image_read_loop_functions=[];
image_read_loop.InstanceName='ProcessingLoop';
image_read_loop.FunctionHandle=@forLoop;
image_read_loop.FunctionArgs.StartLoop.Value=start_frame;
image_read_loop.FunctionArgs.EndLoop.Value=(start_frame+frame_count-1)*frame_step;
image_read_loop.FunctionArgs.IncrementLoop.Value=frame_step;

display_curtrackframe_function.InstanceName='DisplayCurFrame';
display_curtrackframe_function.FunctionHandle=@displayVariable;
display_curtrackframe_function.FunctionArgs.Variable.FunctionInstance='ProcessingLoop';
display_curtrackframe_function.FunctionArgs.Variable.OutputArg='LoopCounter';
display_curtrackframe_function.FunctionArgs.VariableName.Value='Current Tracking Frame';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,display_curtrackframe_function);

make_file_name_function.InstanceName='MakeImageNamesInProcessingLoop';
make_file_name_function.FunctionHandle=@makeImgFileName;
make_file_name_function.FunctionArgs.FileBase.Value=file_root;
make_file_name_function.FunctionArgs.CurFrame.FunctionInstance='ProcessingLoop';
make_file_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_file_name_function.FunctionArgs.NumberFmt.Value=number_fmt;
make_file_name_function.FunctionArgs.FileExt.Value=img_ext;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,make_file_name_function);

read_image_function.InstanceName='ReadImagesInProcessingLoop';
read_image_function.FunctionHandle=@readImage;
read_image_function.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInProcessingLoop';
read_image_function.FunctionArgs.ImageName.OutputArg='FileName';
read_image_function.FunctionArgs.ImageChannel.Value='';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,read_image_function);

if_first_frame_functions=[];
if_first_frame.InstanceName='IfFirstFrame';
if_first_frame.FunctionHandle=@if_statement;
if_first_frame.FunctionArgs.TestResult.FunctionInstance='IsFirstFrame';
if_first_frame.FunctionArgs.TestResult.OutputArg='Boolean';
if_first_frame.TestFunction.InstanceName='IsFirstFrame';
if_first_frame.TestFunction.FunctionHandle=@isFirstFrame;
if_first_frame.TestFunction.FunctionArgs.CurFrame.FunctionInstance='IfFirstFrame';
if_first_frame.TestFunction.FunctionArgs.CurFrame.InputArg='CurFrame'; %only works for subfunctions
if_first_frame.FunctionArgs.CurFrame.FunctionInstance='ProcessingLoop';
if_first_frame.FunctionArgs.CurFrame.OutputArg='LoopCounter';
if_first_frame.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
if_first_frame.FunctionArgs.Image.OutputArg='Image';
if_first_frame.KeepValues.CropSize.FunctionInstance='CalculateCropSize';
if_first_frame.KeepValues.CropSize.OutputArg='CropSize';

    function output_args=isFirstFrame(input_args)
        %nested test function - has access to start_frame
        output_args.Boolean=(start_frame==input_args.CurFrame.Value);
    end

calculate_crop_size.InstanceName='CalculateCropSize';
calculate_crop_size.FunctionHandle=@calculateCropSize;
calculate_crop_size.FunctionArgs.Image.FunctionInstance='IfFirstFrame';
calculate_crop_size.FunctionArgs.Image.InputArg='Image';
calculate_crop_size.FunctionArgs.XYOffsets.Value=frame_offsets;
if_first_frame_functions=addToFunctionChain(if_first_frame_functions,calculate_crop_size);

if_first_frame.IfFunctions=if_first_frame_functions;
if_first_frame.ElseFunctions=[];
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,if_first_frame);

get_current_offset.InstanceName='GetCurrentOffset';
get_current_offset.FunctionHandle=@getArrayVal;
get_current_offset.FunctionArgs.Array.Value=frame_offsets;
get_current_offset.FunctionArgs.Index.FunctionInstance='ProcessingLoop';
get_current_offset.FunctionArgs.Index.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,get_current_offset);

crop_image.InstanceName='CropImage';
crop_image.FunctionHandle=@cropImageWithOffset;
crop_image.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
crop_image.FunctionArgs.Image.OutputArg='Image';
crop_image.FunctionArgs.XYOffset.FunctionInstance='GetCurrentOffset';
crop_image.FunctionArgs.XYOffset.OutputArg='ArrayVal';
crop_image.FunctionArgs.CropSize.FunctionInstance='IfFirstFrame';
crop_image.FunctionArgs.CropSize.OutputArg='CropSize';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,crop_image);

make_output_file_name.InstanceName='MakeOutputImageNames';
make_output_file_name.FunctionHandle=@makeImgFileName;
make_output_file_name.FunctionArgs.FileBase.Value=output_root;
make_output_file_name.FunctionArgs.CurFrame.FunctionInstance='ProcessingLoop';
make_output_file_name.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_output_file_name.FunctionArgs.NumberFmt.Value=number_fmt;
make_output_file_name.FunctionArgs.FileExt.Value=img_ext;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,make_output_file_name);

save_image.InstanceName='SaveImage';
save_image.FunctionHandle=@imwrite_Wrapper;
save_image.FunctionArgs.Image.FunctionInstance='CropImage';
save_image.FunctionArgs.Image.OutputArg='Image';
save_image.FunctionArgs.FileName.FunctionInstance='MakeOutputImageNames';
save_image.FunctionArgs.FileName.OutputArg='FileName';
save_image.FunctionArgs.Format.Value=img_ext(2:end);
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,save_image);

image_read_loop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,image_read_loop);

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end assayGetStageOffset
end