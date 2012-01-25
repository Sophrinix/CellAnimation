function []=assayGetStageOffset()
%assayGetStageOffset - This assay is used to calculate the microscope stage offset at each frame 
%  by manually  clicking on a fixed point in every image. ImageFolder 
%-  String  variable that specifies the absolute location of the directory which 
%contains the   time-lapse  images. An example of such a string variable 
%would be 'c:/sample  images/high-density'. ImageFilesRoot -  String variable specifying the root image 
%file name. The root  image file name   for a set of 
%images is the image file  name of any of the   images 
%without the number or the file  extension. For example, if the file  
%name  is 'Experiment-0002_Position(8)_t021.tif' the root image  file name will be 'Experiment-0002_Position(8)_t'. ImageFileBase 
%-  The path name to the images.  This value is generated from 
%the ImageFolder   and the ImageFilesRoot and should  not be changed. ImageExtension 
%- String variable specifying the  image file extension including  the preceding dot. 
%For example  if the file name  is 'image003.jpg' the  image extension 
%is '.jpg'. NumberFormat - String value specifying the number  of digits  in 
%the image file names in  the sequence. For example if  the  
%image file name is 'image020.jpg' the value for  the NumberFormat is '%03d',  
% while if the file name is 'image000020.jpg' the value should  be '%06d'. 
%StartFrame   - Number specifying the first image in the sequence to be 
%analyzed. The  minimum   value for this variable depends on the numbering 
%of the image  sequence so  if  the first image in the 
%sequence is 'image003.tif' then  the minimum value  is 3. FrameStep - Number 
%specifying the step size when  reading images. Set this  variable to 1 
% to read every image in  the sequence, 2 to read  every 
%other image and  so on. FrameCount  - Number specifying how many images 
% from the image sequence should be processed.  XYOffsets - Initial value for 
%the stage  offsets array. Set to zero by  default. Important Modules - 
%None.

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
processingloop.KeepValues.SetOffset_Array.FunctionInstance='SetOffset';
processingloop.KeepValues.SetOffset_Array.OutputArg='Array';
processingloop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,processingloop);

getfirstoffset.InstanceName='GetFirstOffset';
getfirstoffset.FunctionHandle=@getArrayVal;
getfirstoffset.FunctionArgs.Index.Value=1;
getfirstoffset.FunctionArgs.Array.FunctionInstance='ProcessingLoop';
getfirstoffset.FunctionArgs.Array.OutputArg='SetOffset_Array';
functions_list=addToFunctionChain(functions_list,getfirstoffset);

replicatefirstoffset.InstanceName='ReplicateFirstOffset';
replicatefirstoffset.FunctionHandle=@repmat_Wrapper;
replicatefirstoffset.FunctionArgs.RepeatDim.Value=[FrameCount 1];
replicatefirstoffset.FunctionArgs.Matrix.FunctionInstance='GetFirstOffset';
replicatefirstoffset.FunctionArgs.Matrix.OutputArg='ArrayVal';
functions_list=addToFunctionChain(functions_list,replicatefirstoffset);

subtractfirstoffset.InstanceName='SubtractFirstOffset';
subtractfirstoffset.FunctionHandle=@subtractFunction;
subtractfirstoffset.FunctionArgs.Number2.FunctionInstance='ReplicateFirstOffset';
subtractfirstoffset.FunctionArgs.Number2.OutputArg='Matrix';
subtractfirstoffset.FunctionArgs.Number1.FunctionInstance='ProcessingLoop';
subtractfirstoffset.FunctionArgs.Number1.OutputArg='SetOffset_Array';
functions_list=addToFunctionChain(functions_list,subtractfirstoffset);

saveoffsets.InstanceName='SaveOffsets';
saveoffsets.FunctionHandle=@saveOffsets;
saveoffsets.FunctionArgs.FileName.Value=[ImageFolder '/xyoffsets.mat'];
saveoffsets.FunctionArgs.XYOffsets.FunctionInstance='SubtractFirstOffset';
saveoffsets.FunctionArgs.XYOffsets.OutputArg='Difference';
functions_list=addToFunctionChain(functions_list,saveoffsets);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end