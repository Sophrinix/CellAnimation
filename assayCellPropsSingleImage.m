function []=assayCellPropsSingleImage()
%assayCellPropsSingleImage - This assay is used to segment objects in an image subject to manual 
%review then  extract their shape properties.  ImageDirName - String variable specifying where 
%the directory where the image to be analyzed is  located. An example of 
%such a variable would be 'c:/test/'. FileRoot - String variable specifying the image file 
%name without the extension. For example, if  the file name is 'Experiment-0002_Position(8)_t021.tif' the 
%root file name will be 'Experiment-0002_Position(8)_t021'. ImageExt - String variable specifying the extension of 
%the image file name. For example, if  the file name is 'Experiment-0002_Position(8)_t021.tif' the 
%root file name will be '.tif'. ImageFileName - String variable that is automatically generated 
%from the ImageDirName, FileRoot and ImageExt. OutputDir - String variable specifying the directory where 
%the spreadsheet containing the shape properties and  the label matrix containing the cell 
%outlines will be saved. SpreadsheetFileName - String variable specifying the file name of the 
%spreadsheet containing the shape properties  of the objects in the original image. This 
%variable is automatically generated from the  OutputDir and FileRoot variables. LabelFileName - String 
%variable specifying the file name of the label matrix containing the detected  objects 
%in the original image. This variable is automatically generated from the OutputDir and  
%FileRoot variables. BrightnessGradientThreshold - Number specifying the threshold value for the image generated by 
%the generateBinImgUsingLocAvg filter.  Any pixels in the gradient image below this value will 
%be set to zero  while the rest will be set to one. ClearBorder 
%- Boolean value specifying whether objects next to or touching the image border in 
% the binary images generated by the generateBinImgUsingGradient module will be erased (true) or 
%not  (false). ClearBorderDist - Number specifying how close to the border objects may 
%be and still be  erased if the ClearBorder parameter is set to true 
%in the generateBinImgUsingGradient module. MedianFilterSize - Number specifying the size of the median filter 
%used by the distanceWatershed module.  Setting this to a higher integer value will 
%reduce the number of objects detected  by the module and can be used 
%to prevent oversegmentation. ObjectArea - Number specifying the threshold area for the clearSmallObjects filter. 
%Objects below this value  will be removed from the filtered image. Strel - 
%String variable specifying the type of filter used to generate the local average  
%image in generateBinImgUsingLocAvg. Currently 'disk' is the only value supported. StrelSize - Number specifying 
%the size of the local neighborhood used to calculate the average  for each 
%pixel in the local average image generated by the generateBinImgUsingLocAvg module.  Important Modules 
%- clearSmallObjects, distanceWatershed, generateBinImgUsingLocAvg, manualSegmentationReview, segmentObjectsUsingMarkers.

global functions_list;
functions_list=[];
%script variables
ImageDirName='C:/walter/20071104/';
FileRoot='20071104 ha ht-1080 af488coll4 10ugperml  then af488coll4 1ugperml milk 35 mm bac pd_t001';
ImageExt='.TIF';
ImageFileName=[ImageDirName FileRoot ImageExt];
OutputDir='c:/walter/';
SpreadsheetFileName=[OutputDir FileRoot '.csv'];
LabelFileName=[OutputDir FileRoot '.mat'];
BrightnessThresholdPct=1.2;
ClearBorder=false;
ClearBorderDist=0;
MedianFilterSize=3;
ObjectArea=30;
Strel='disk';
StrelSize=10;
%end script variables


getfileinfo.InstanceName='GetFileInfo';
getfileinfo.FunctionHandle=@getFileInfo;
getfileinfo.FunctionArgs.DirSep.Value='/';
getfileinfo.FunctionArgs.PathName.Value=ImageFileName;
functions_list=addToFunctionChain(functions_list,getfileinfo);

readimage.InstanceName='ReadImage';
readimage.FunctionHandle=@readImage;
readimage.FunctionArgs.ImageName.Value=ImageFileName;
readimage.FunctionArgs.ImageChannel.Value='';
functions_list=addToFunctionChain(functions_list,readimage);

normalizeimageto16bit.InstanceName='NormalizeImageTo16Bit';
normalizeimageto16bit.FunctionHandle=@imNorm;
normalizeimageto16bit.FunctionArgs.IntegerClass.Value='uint16';
normalizeimageto16bit.FunctionArgs.RawImage.FunctionInstance='ReadImage';
normalizeimageto16bit.FunctionArgs.RawImage.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,normalizeimageto16bit);

displaynormalizedimage.InstanceName='DisplayNormalizedImage';
displaynormalizedimage.FunctionHandle=@displayImage;
displaynormalizedimage.FunctionArgs.FigureNr.Value=1;
displaynormalizedimage.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
displaynormalizedimage.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,displaynormalizedimage);

negativeimage.InstanceName='NegativeImage';
negativeimage.FunctionHandle=@imcomplementWrapper;
negativeimage.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
negativeimage.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,negativeimage);

localaveragingfilter.InstanceName='LocalAveragingFilter';
localaveragingfilter.FunctionHandle=@generateBinImgUsingLocAvg;
localaveragingfilter.FunctionArgs.Strel.Value=Strel;
localaveragingfilter.FunctionArgs.StrelSize.Value=StrelSize;
localaveragingfilter.FunctionArgs.BrightnessThresholdPct.Value=BrightnessThresholdPct;
localaveragingfilter.FunctionArgs.ClearBorder.Value=ClearBorder;
localaveragingfilter.FunctionArgs.ClearBorderDist.Value=ClearBorderDist;
localaveragingfilter.FunctionArgs.Image.FunctionInstance='NegativeImage';
localaveragingfilter.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,localaveragingfilter);

fillholesimage.InstanceName='FillHolesImage';
fillholesimage.FunctionHandle=@fillHoles;
fillholesimage.FunctionArgs.Image.FunctionInstance='LocalAveragingFilter';
fillholesimage.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,fillholesimage);

clearsmallobjects.InstanceName='ClearSmallObjects';
clearsmallobjects.FunctionHandle=@clearSmallObjects;
clearsmallobjects.FunctionArgs.MinObjectArea.Value=ObjectArea;
clearsmallobjects.FunctionArgs.Image.FunctionInstance='FillHolesImage';
clearsmallobjects.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,clearsmallobjects);

displaythresholdedimage.InstanceName='DisplayThresholdedImage';
displaythresholdedimage.FunctionHandle=@displayImage;
displaythresholdedimage.FunctionArgs.FigureNr.Value=2;
displaythresholdedimage.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
displaythresholdedimage.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,displaythresholdedimage);

labelobjects.InstanceName='LabelObjects';
labelobjects.FunctionHandle=@labelObjects;
labelobjects.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
labelobjects.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,labelobjects);

distancewatershed.InstanceName='DistanceWatershed';
distancewatershed.FunctionHandle=@distanceWatershed;
distancewatershed.FunctionArgs.MedianFilterNhood.Value=MedianFilterSize;
distancewatershed.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
distancewatershed.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,distancewatershed);

segmentobjectsusingmarkers.InstanceName='SegmentObjectsUsingMarkers';
segmentobjectsusingmarkers.FunctionHandle=@segmentObjectsUsingMarkers;
segmentobjectsusingmarkers.FunctionArgs.MarkersLabel.FunctionInstance='DistanceWatershed';
segmentobjectsusingmarkers.FunctionArgs.MarkersLabel.OutputArg='LabelMatrix';
segmentobjectsusingmarkers.FunctionArgs.ObjectsLabel.FunctionInstance='LabelObjects';
segmentobjectsusingmarkers.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,segmentobjectsusingmarkers);

reviewsegmentation.InstanceName='ReviewSegmentation';
reviewsegmentation.FunctionHandle=@manualSegmentationReview;
reviewsegmentation.FunctionArgs.PreviousLabel.Value=[];
reviewsegmentation.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentObjectsUsingMarkers';
reviewsegmentation.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
reviewsegmentation.FunctionArgs.RawLabel.FunctionInstance='LabelObjects';
reviewsegmentation.FunctionArgs.RawLabel.OutputArg='LabelMatrix';
reviewsegmentation.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
reviewsegmentation.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,reviewsegmentation);

getregionprops.InstanceName='GetRegionProps';
getregionprops.FunctionHandle=@getRegionProps;
getregionprops.FunctionArgs.LabelMatrix.FunctionInstance='ReviewSegmentation';
getregionprops.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,getregionprops);

saveregionprops.InstanceName='SaveRegionProps';
saveregionprops.FunctionHandle=@saveRegionPropsSpreadsheets;
saveregionprops.FunctionArgs.SpreadsheetFileName.Value=SpreadsheetFileName;
saveregionprops.FunctionArgs.RegionProps.FunctionInstance='GetRegionProps';
saveregionprops.FunctionArgs.RegionProps.OutputArg='RegionProps';
functions_list=addToFunctionChain(functions_list,saveregionprops);

savelabel.InstanceName='SaveLabel';
savelabel.FunctionHandle=@saveWrapper;
savelabel.FunctionArgs.FileName.Value=LabelFileName;
savelabel.FunctionArgs.SaveData.FunctionInstance='ReviewSegmentation';
savelabel.FunctionArgs.SaveData.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,savelabel);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end