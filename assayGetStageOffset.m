function []=assayGetStageOffset()
%Usage This assay is used to calculate the microscope stage offset at each frame by 
%  manually clicking on a fixed point at each frame.

global functions_list;
functions_list=[];
%script variables
ImageFolder='C:/peter/cropped';
ImageFilesRoot='peter';
ImageFileBase=[ImageFolder '/' ImageFilesRoot];
ImageExtension='.tif';
NumberFormat='%06d';
StartFrame=1;
FrameStep=1;
FrameCount=10;
XYOffsets=zeros(FrameCount,2);
%end script variables

image_read_loop_functions=[];

displaycurframe.InstanceName='DisplayCurFrame';
displaycurframe.FunctionHandle=@displayVariable;
displaycurframe.FunctionArgs.VariableName.Value='Current Tracking Frame';
displaycurframe.FunctionArgs.Variable.FunctionInstance='ProcessingLoop';
displaycurframe.FunctionArgs.Variable.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,displaycurframe);

makeimagenamesinprocessingloop.InstanceName='MakeImageNamesInProcessingLoop';
makeimagenamesinprocessingloop.FunctionHandle=@makeImgFileName;
makeimagenamesinprocessingloop.FunctionArgs.FileBase.Value=ImageFileBase;
makeimagenamesinprocessingloop.FunctionArgs.NumberFmt.Value=NumberFormat;
makeimagenamesinprocessingloop.FunctionArgs.FileExt.Value=ImageExtension;
makeimagenamesinprocessingloop.FunctionArgs.CurFrame.FunctionInstance='ProcessingLoop';
makeimagenamesinprocessingloop.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,makeimagenamesinprocessingloop);

readimagesinprocessingloop.InstanceName='ReadImagesInProcessingLoop';
readimagesinprocessingloop.FunctionHandle=@readImage;
readimagesinprocessingloop.FunctionArgs.ImageChannel.Value='';
readimagesinprocessingloop.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInProcessingLoop';
readimagesinprocessingloop.FunctionArgs.ImageName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,readimagesinprocessingloop);

displayimage.InstanceName='DisplayImage';
displayimage.FunctionHandle=@displayImage;
displayimage.FunctionArgs.FigureNr.Value=1;
displayimage.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
displayimage.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,displayimage);

getxycoordinates.InstanceName='GetXYCoordinates';
getxycoordinates.FunctionHandle=@ginput_Wrapper;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,getxycoordinates);

setoffset.InstanceName='SetOffset';
setoffset.FunctionHandle=@setArrayVar;
setoffset.FunctionArgs.Array.Value=XYOffsets;
setoffset.FunctionArgs.Index.FunctionInstance='ProcessingLoop';
setoffset.FunctionArgs.Index.OutputArg='LoopCounter';
setoffset.FunctionArgs.Var.FunctionInstance='GetXYCoordinates';
setoffset.FunctionArgs.Var.OutputArg='XYCoords';
setoffset.FunctionArgs.Array.FunctionInstance='SetOffset';
setoffset.FunctionArgs.Array.OutputArg='Array';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,setoffset);

processingloop.InstanceName='ProcessingLoop';
processingloop.FunctionHandle=@forLoop;
processingloop.FunctionArgs.StartLoop.Value=StartFrame;
processingloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
processingloop.FunctionArgs.IncrementLoop.Value=FrameStep;
processingloop.FunctionArgs.OffsetArray.Value=XYOffsets;
processingloop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,processingloop);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end