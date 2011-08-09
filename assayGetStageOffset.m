function xy_offsets=assayGetStageOffset(file_root,frame_count,varargin)
%Usage
%This assay is used to calculate the microscope stage offset at each frame by manually clicking
%on a fixed point at each frame.
%
%Important Parameters
%file_root – The root file name of the image series. For example if the image series
%is “image001.jpg”, “image002.jpg”, etc. the root file name will be “image”.
%frame_count – The number of frames to analyze.
%FrameStep – Optional. Read one out of every x frames when reading the image set. Default
%value is one meaning every frame will be read.
%ImageExtension – The image extension of the images in the series (usually, “.tif” or “.jpg”).
%NumberFormat – String representing the format of the counter in the image series. Follows
%sprintf format.
%StartFrame – Index indicating starting image from which the image sequence will be read.
%
%Important Modules
%None.

global functions_list;
functions_list=[];

frame_step=1;
img_ext='.tif';
number_fmt='%06d';
start_frame=1;

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
    end
end

xy_offsets=zeros(frame_count,2);

image_read_loop_functions=[];
image_read_loop.InstanceName='ProcessingLoop';
image_read_loop.FunctionHandle=@forLoop;
image_read_loop.FunctionArgs.StartLoop.Value=start_frame;
image_read_loop.FunctionArgs.EndLoop.Value=(start_frame+frame_count-1)*frame_step;
image_read_loop.FunctionArgs.IncrementLoop.Value=frame_step;
image_read_loop.FunctionArgs.OffsetArray.Value=xy_offsets; %need to add another provider
image_read_loop.FunctionArgs.OffsetArray.FunctionInstance='SetOffset';
image_read_loop.FunctionArgs.OffsetArray.OutputArg='Array';
image_read_loop.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.KeepValues.OffsetArray.FunctionInstance='SetOffset';
image_read_loop.KeepValues.OffsetArray.OutputArg='Array';

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

% enhance_contrast_function.InstanceName='EnhanceContrast';
% enhance_contrast_function.FunctionHandle=@imadjust_Wrapper;
% enhance_contrast_function.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
% enhance_contrast_function.FunctionArgs.Image.OutputArg='Image';
% image_read_loop_functions=addToFunctionChain(image_read_loop_functions,enhance_contrast_function);

display_image_function.InstanceName='DisplayImage';
display_image_function.FunctionHandle=@displayImage;
display_image_function.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
display_image_function.FunctionArgs.Image.OutputArg='Image';
display_image_function.FunctionArgs.FigureNr.Value=1;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,display_image_function);

ginput_function.InstanceName='GetXYCoordinates';
ginput_function.FunctionHandle=@ginput_Wrapper;
ginput_function.FunctionArgs=[];
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,ginput_function);

set_offset_function.InstanceName='SetOffset';
set_offset_function.FunctionHandle=@setArrayVar;
set_offset_function.FunctionArgs.Array.FunctionInstance='ProcessingLoop';
set_offset_function.FunctionArgs.Array.InputArg='OffsetArray';
set_offset_function.FunctionArgs.Index.FunctionInstance='ProcessingLoop';
set_offset_function.FunctionArgs.Index.OutputArg='LoopCounter';
set_offset_function.FunctionArgs.Var.FunctionInstance='GetXYCoordinates';
set_offset_function.FunctionArgs.Var.OutputArg='XYCoords';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,set_offset_function);

image_read_loop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,image_read_loop);
%nested function to extract the populated offset array
    function output_args=getOffsetArray(input_args)
        %setting the xy_offsets in the parent function - the nested function
        %could be set_offset in the loop to save memory and there will be no need for this function. sort of untidy to
        %pull from the loop to the main function though.
        xy_offsets=input_args.XYArray.Value;
        output_args=[];
    end
%add the nested function to the function chain
get_offset_function.InstanceName='GetOffsetArray';
get_offset_function.FunctionHandle=@getOffsetArray;
get_offset_function.FunctionArgs.XYArray.FunctionInstance='ProcessingLoop';
get_offset_function.FunctionArgs.XYArray.OutputArg='OffsetArray';
functions_list=addToFunctionChain(functions_list,get_offset_function);

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

xy_offsets=xy_offsets-repmat(xy_offsets(1,:),length(xy_offsets),1);

%end assayGetStageOffset
end
