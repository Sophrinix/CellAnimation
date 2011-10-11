function []=assayOffsetFrames()
%Usage This module is used to offset and crop frames to remove incorrect offsets due 
% to errors in automatic stage return. Use with offset data acquired using an 
%assay  such as assayGetStageOffset. The original images will be untouched and the cropped 
%images will  be saved in a âÿÿcropped framesâÿ? directory under the original image 
%folder.

global functions_list;
functions_list=[];
%script variables
ImagesFolder='C:/peter/cropped';
ImageFilesRoot='peter';
ImageFileBase=[ImagesFolder '/' ImageFilesRoot];
CroppedImagesFolder=[ImagesFolder '/cropped frames'];
ImageExtension='.tif';
NumberFormat='%06d';
StartFrame=1;
FrameStep=1;
FrameCount=10;
%end script variables

if_first_frame_functions=[];
image_read_loop_functions=[];

makedirectory.InstanceName='MakeDirectory';
makedirectory.FunctionHandle=@mkdir_Wrapper;
makedirectory.FunctionArgs.DirectoryName.Value=CroppedImagesFolder;
functions_list=addToFunctionChain(functions_list,makedirectory);

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

loadoffsets.InstanceName='LoadOffsets';
loadoffsets.FunctionHandle=@loadOffsets;
loadoffsets.FunctionArgs.FileName.Value=[ImagesFolder '/xyoffsets.mat'];
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,loadoffsets);

isfirstframe.InstanceName='IsFirstFrame';
isfirstframe.FunctionHandle=@isEqualFunction;
isfirstframe.FunctionArgs.Var2.Value=StartFrame;
isfirstframe.FunctionArgs.Var1.FunctionInstance='ProcessingLoop';
isfirstframe.FunctionArgs.Var1.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,isfirstframe);

calculatecropsize.InstanceName='CalculateCropSize';
calculatecropsize.FunctionHandle=@calculateCropSize;
calculatecropsize.FunctionArgs.Image.FunctionInstance='IfFirstFrame';
calculatecropsize.FunctionArgs.Image.InputArg='ReadImagesInProcessingLoop_Image';
calculatecropsize.FunctionArgs.XYOffsets.FunctionInstance='IfFirstFrame';
calculatecropsize.FunctionArgs.XYOffsets.InputArg='LoadOffsets_Offsets';
if_first_frame_functions=addToFunctionChain(if_first_frame_functions,calculatecropsize);

iffirstframe.InstanceName='IfFirstFrame';
iffirstframe.FunctionHandle=@if_statement;
iffirstframe.FunctionArgs.TestVariable.FunctionInstance='IsFirstFrame';
iffirstframe.FunctionArgs.TestVariable.OutputArg='Boolean';
iffirstframe.FunctionArgs.ReadImagesInProcessingLoop_Image.FunctionInstance='ReadImagesInProcessingLoop';
iffirstframe.FunctionArgs.ReadImagesInProcessingLoop_Image.OutputArg='Image';
iffirstframe.FunctionArgs.LoadOffsets_Offsets.FunctionInstance='LoadOffsets';
iffirstframe.FunctionArgs.LoadOffsets_Offsets.OutputArg='Offsets';
iffirstframe.KeepValues.CalculateCropSize_CropSize.FunctionInstance='CalculateCropSize';
iffirstframe.KeepValues.CalculateCropSize_CropSize.OutputArg='CropSize';
iffirstframe.IfFunctions=if_first_frame_functions;
iffirstframe.ElseFunctions=[];
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,iffirstframe);

getcurrentoffset.InstanceName='GetCurrentOffset';
getcurrentoffset.FunctionHandle=@getArrayVal;
getcurrentoffset.FunctionArgs.Array.FunctionInstance='LoadOffsets';
getcurrentoffset.FunctionArgs.Array.OutputArg='Offsets';
getcurrentoffset.FunctionArgs.Index.FunctionInstance='ProcessingLoop';
getcurrentoffset.FunctionArgs.Index.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,getcurrentoffset);

cropimage.InstanceName='CropImage';
cropimage.FunctionHandle=@cropImageWithOffset;
cropimage.FunctionArgs.Image.FunctionInstance='ReadImagesInProcessingLoop';
cropimage.FunctionArgs.Image.OutputArg='Image';
cropimage.FunctionArgs.XYOffset.FunctionInstance='GetCurrentOffset';
cropimage.FunctionArgs.XYOffset.OutputArg='ArrayVal';
cropimage.FunctionArgs.CropSize.FunctionInstance='IfFirstFrame';
cropimage.FunctionArgs.CropSize.OutputArg='CalculateCropSize_CropSize';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,cropimage);

makeoutputimagenames.InstanceName='MakeOutputImageNames';
makeoutputimagenames.FunctionHandle=@makeImgFileName;
makeoutputimagenames.FunctionArgs.FileBase.Value=[CroppedImagesFolder '/' ImageFilesRoot];
makeoutputimagenames.FunctionArgs.NumberFmt.Value=NumberFormat;
makeoutputimagenames.FunctionArgs.FileExt.Value=ImageExtension;
makeoutputimagenames.FunctionArgs.CurFrame.FunctionInstance='ProcessingLoop';
makeoutputimagenames.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,makeoutputimagenames);

saveimage.InstanceName='SaveImage';
saveimage.FunctionHandle=@imwrite_Wrapper;
saveimage.FunctionArgs.Format.Value=ImageExtension(2:end);
saveimage.FunctionArgs.Image.FunctionInstance='CropImage';
saveimage.FunctionArgs.Image.OutputArg='Image';
saveimage.FunctionArgs.FileName.FunctionInstance='MakeOutputImageNames';
saveimage.FunctionArgs.FileName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,saveimage);

processingloop.InstanceName='ProcessingLoop';
processingloop.FunctionHandle=@forLoop;
processingloop.FunctionArgs.StartLoop.Value=StartFrame;
processingloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
processingloop.FunctionArgs.IncrementLoop.Value=FrameStep;
processingloop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,processingloop);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end