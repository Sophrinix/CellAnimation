function []=assayFluoNuclThresholding()
%assayFluoNuclThresholding - This module is used to threshold a series of images (no object segmentation 
% and no  tracking are performed).  ImageFolder - String variable that specifies 
%the  absolute location of the directory which contains the  time-lapse images. An 
%example of  such a string variable would be 'c:/sample images/high-density'. ImageFilesRoot - String 
%variable specifying the  root image file name. The root image file name  
%for a set of  images is the image file name of any of 
%the  images without the  number or the file extension. For example, if 
%the file name  is 'Experiment-0002_Position(8)_t021.tif'  the root image file name will be 
%'Experiment-0002_Position(8)_t'. ImageExtension - String variable specifying the  image file extension including the preceding 
%dot. For example  if the file name  is 'image003.jpg' the image extension 
%is '.jpg'. StartFrame - Number specifying the first image  in the sequence to 
%be analyzed. The minimum  value for this variable depends  on the numbering 
%of the image sequence so if  the first image in  the sequence 
%is 'image003.tif' then the minimum value is 3. FrameCount - Number specifying  how 
%many images from the image sequence should be processed. FrameStep - Number specifying  
%the step size when reading images. Set this variable to 1  to read 
% every image in the sequence, 2 to read every other image and  
%so  on. NumberFormat - String value specifying the number of digits in the 
%image file  names in  the sequence. For example if the image file 
%name is 'image020.jpg'  the value for  the NumberFormat is '%03d', while if 
%the file name is  'image000020.jpg' the value should  be '%06d'. OutputFolder - 
%The folder where the thresholded  images will be saved. By default this value 
% is set to a folder  named 'output' within the folder where the 
%images to  be analyzed are located.  BrightnessThresholdPct - Number specifying the percentage 
%threshold value for the image generated by the  generateBinImgUsingLocAvg  filter. Any pixel 
%in the original image smaller than the threshold value  times the  corresponding 
%value in the local average image below this value will  be set to 
% zero while the rest will be set to one. ClearBorder  - Boolean 
%value specifying whether objects next to or touching the image border in   
%the binary images generated by the generateBinImgUsingGradient module will be erased (true) or  
%not  (false). ClearBorderDist - Number specifying how close to the border objects may 
% be and still be  erased if the ClearBorder parameter is set to 
%true  in the generateBinImgUsingGradient module. ObjectArea - Number specifying the threshold area for 
%the clearSmallObjects,  polygonalAssistedWatershed filter. Objects below this  value will be removed from 
%the filtered image.  Strel - String variable specifying the type of filter used 
%to generate the local  average  image in generateBinImgUsingLocAvg. Currently 'disk' is the 
%only value supported. StrelSize -  Number specifying the size of the local neighborhood 
%used to calculate the average   for each pixel in the local average 
%image generated by the generateBinImgUsingLocAvg module. Important  Modules - generateBinImgUsingLocAvg.

global functions_list;
functions_list=[];
%script variables
ImageFolder='C:/sample movies/low density';
ImageFilesRoot='low density sample';
ImageExtension='.tif';
StartFrame=1;
FrameCount=10;
FrameStep=1;
NumberFormat='%06d';
OutputFolder=[ImageFolder '/output'];
BrightnessThresholdPct=1.1;
ClearBorder=true;
ClearBorderDist=2;
ObjectArea=30;
Strel='disk';
StrelSize=10;
%end script variables

image_read_loop_functions=[];

makeoutputdir.InstanceName='MakeOutputDir';
makeoutputdir.FunctionHandle=@mkdir_Wrapper;
makeoutputdir.FunctionArgs.DirectoryName.Value=OutputFolder;
functions_list=addToFunctionChain(functions_list,makeoutputdir);

displaycurframe.InstanceName='DisplayCurFrame';
displaycurframe.FunctionHandle=@displayVariable;
displaycurframe.FunctionArgs.VariableName.Value='Current Tracking Frame';
displaycurframe.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
displaycurframe.FunctionArgs.Variable.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,displaycurframe);

makeimagenamesinsegmentationloop.InstanceName='MakeImageNamesInSegmentationLoop';
makeimagenamesinsegmentationloop.FunctionHandle=@makeImgFileName;
makeimagenamesinsegmentationloop.FunctionArgs.FileBase.Value=[ImageFolder '/' ImageFilesRoot];
makeimagenamesinsegmentationloop.FunctionArgs.NumberFmt.Value=NumberFormat;
makeimagenamesinsegmentationloop.FunctionArgs.FileExt.Value=ImageExtension;
makeimagenamesinsegmentationloop.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
makeimagenamesinsegmentationloop.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,makeimagenamesinsegmentationloop);

readimagesinsegmentationloop.InstanceName='ReadImagesInSegmentationLoop';
readimagesinsegmentationloop.FunctionHandle=@readImage;
readimagesinsegmentationloop.FunctionArgs.ImageChannel.Value='';
readimagesinsegmentationloop.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInSegmentationLoop';
readimagesinsegmentationloop.FunctionArgs.ImageName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,readimagesinsegmentationloop);

normalizeimageto16bit.InstanceName='NormalizeImageTo16Bit';
normalizeimageto16bit.FunctionHandle=@imNorm;
normalizeimageto16bit.FunctionArgs.IntegerClass.Value='uint16';
normalizeimageto16bit.FunctionArgs.RawImage.FunctionInstance='ReadImagesInSegmentationLoop';
normalizeimageto16bit.FunctionArgs.RawImage.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,normalizeimageto16bit);

cytobrightnesslocalaveragingfilter.InstanceName='CytoBrightnessLocalAveragingFilter';
cytobrightnesslocalaveragingfilter.FunctionHandle=@generateBinImgUsingLocAvg;
cytobrightnesslocalaveragingfilter.FunctionArgs.Strel.Value=Strel;
cytobrightnesslocalaveragingfilter.FunctionArgs.StrelSize.Value=StrelSize;
cytobrightnesslocalaveragingfilter.FunctionArgs.BrightnessThresholdPct.Value=BrightnessThresholdPct;
cytobrightnesslocalaveragingfilter.FunctionArgs.ClearBorder.Value=ClearBorder;
cytobrightnesslocalaveragingfilter.FunctionArgs.ClearBorderDist.Value=ClearBorderDist;
cytobrightnesslocalaveragingfilter.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
cytobrightnesslocalaveragingfilter.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,cytobrightnesslocalaveragingfilter);

fillholescytoplasmimages.InstanceName='FillHolesCytoplasmImages';
fillholescytoplasmimages.FunctionHandle=@fillHoles;
fillholescytoplasmimages.FunctionArgs.Image.FunctionInstance='CytoBrightnessLocalAveragingFilter';
fillholescytoplasmimages.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,fillholescytoplasmimages);

clearsmallcells.InstanceName='ClearSmallCells';
clearsmallcells.FunctionHandle=@clearSmallObjects;
clearsmallcells.FunctionArgs.MinObjectArea.Value=ObjectArea;
clearsmallcells.FunctionArgs.Image.FunctionInstance='FillHolesCytoplasmImages';
clearsmallcells.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,clearsmallcells);

makethresholdimagenames.InstanceName='MakeThresholdImageNames';
makethresholdimagenames.FunctionHandle=@makeImgFileName;
makethresholdimagenames.FunctionArgs.FileBase.Value=[OutputFolder '/' ImageFilesRoot];
makethresholdimagenames.FunctionArgs.FileExt.Value=ImageExtension;
makethresholdimagenames.FunctionArgs.NumberFmt.Value=NumberFormat;
makethresholdimagenames.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
makethresholdimagenames.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,makethresholdimagenames);

saveimage.InstanceName='SaveImage';
saveimage.FunctionHandle=@imwrite_Wrapper;
saveimage.FunctionArgs.Format.Value=ImageExtension(2:end);
saveimage.FunctionArgs.Image.FunctionInstance='ClearSmallCells';
saveimage.FunctionArgs.Image.OutputArg='Image';
saveimage.FunctionArgs.FileName.FunctionInstance='MakeThresholdImageNames';
saveimage.FunctionArgs.FileName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,saveimage);

segmentationloop.InstanceName='SegmentationLoop';
segmentationloop.FunctionHandle=@forLoop;
segmentationloop.FunctionArgs.StartLoop.Value=StartFrame;
segmentationloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
segmentationloop.FunctionArgs.IncrementLoop.Value=FrameStep;
segmentationloop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,segmentationloop);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end