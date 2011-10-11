function []=assayFlCytoLNCapManSegWG()
%Usage This assay is used to manually review segmentation of objects labeled using a fluorescent 
%dye after they have been segmented using another assay.

global functions_list;
functions_list=[];
%script variables
ImageFolder='C:/peter/cropped';
ImageFilesRoot='peter';
ImageExtension='.tif';
StartFrame=1;
FrameCount=10;
FrameStep=1;
NumberFormat='%06d';
OutputFolder=[ImageFolder '/output'];
TracksFolder=[OutputFolder '/track'];
SegmentationFilesRoot=[TracksFolder '/grayscale'];
ImageFileBase=[ImageFolder '/' ImageFilesRoot];
ApproximationDistance=2.4;
BrightnessThresholdPct=1.1;
ClearBorder=true;
ClearBorderDist=2;
MedianFilterSize=3;
ObjectArea=30;
Strel='disk';
StrelSize=10;
ResizeImageScale=0.5;
ResizeLabelMatrixScale=2;
%end script variables

image_read_loop_functions=[];

displaycurframe.InstanceName='DisplayCurFrame';
displaycurframe.FunctionHandle=@displayVariable;
displaycurframe.FunctionArgs.VariableName.Value='Current Tracking Frame';
displaycurframe.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
displaycurframe.FunctionArgs.Variable.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,displaycurframe);

makeimagenamesinsegmentationloop.InstanceName='MakeImageNamesInSegmentationLoop';
makeimagenamesinsegmentationloop.FunctionHandle=@makeImgFileName;
makeimagenamesinsegmentationloop.FunctionArgs.FileBase.Value=ImageFileBase;
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

resizeimage.InstanceName='ResizeImage';
resizeimage.FunctionHandle=@resizeImage;
resizeimage.FunctionArgs.Scale.Value=ResizeImageScale;
resizeimage.FunctionArgs.Method.Value='bicubic';
resizeimage.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
resizeimage.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,resizeimage);

cytobrightnesslocalaveragingfilter.InstanceName='CytoBrightnessLocalAveragingFilter';
cytobrightnesslocalaveragingfilter.FunctionHandle=@generateBinImgUsingLocAvg;
cytobrightnesslocalaveragingfilter.FunctionArgs.Strel.Value=Strel;
cytobrightnesslocalaveragingfilter.FunctionArgs.StrelSize.Value=StrelSize;
cytobrightnesslocalaveragingfilter.FunctionArgs.BrightnessThresholdPct.Value=BrightnessThresholdPct;
cytobrightnesslocalaveragingfilter.FunctionArgs.ClearBorder.Value=ClearBorder;
cytobrightnesslocalaveragingfilter.FunctionArgs.ClearBorderDist.Value=ClearBorderDist;
cytobrightnesslocalaveragingfilter.FunctionArgs.Image.FunctionInstance='ResizeImage';
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

nuclbrightnesslocalaveragingfilter.InstanceName='NuclBrightnessLocalAveragingFilter';
nuclbrightnesslocalaveragingfilter.FunctionHandle=@generateBinImgUsingLocAvg;
nuclbrightnesslocalaveragingfilter.FunctionArgs.Strel.Value=Strel;
nuclbrightnesslocalaveragingfilter.FunctionArgs.StrelSize.Value=StrelSize;
nuclbrightnesslocalaveragingfilter.FunctionArgs.BrightnessThresholdPct.Value=BrightnessThresholdPct;
nuclbrightnesslocalaveragingfilter.FunctionArgs.ClearBorder.Value=ClearBorder;
nuclbrightnesslocalaveragingfilter.FunctionArgs.ClearBorderDist.Value=ClearBorderDist;
nuclbrightnesslocalaveragingfilter.FunctionArgs.Image.FunctionInstance='ResizeImage';
nuclbrightnesslocalaveragingfilter.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,nuclbrightnesslocalaveragingfilter);

fillholesnuclearimages.InstanceName='FillHolesNuclearImages';
fillholesnuclearimages.FunctionHandle=@fillHoles;
fillholesnuclearimages.FunctionArgs.Image.FunctionInstance='NuclBrightnessLocalAveragingFilter';
fillholesnuclearimages.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,fillholesnuclearimages);

clearsmallnuclei.InstanceName='ClearSmallNuclei';
clearsmallnuclei.FunctionHandle=@clearSmallObjects;
clearsmallnuclei.FunctionArgs.MinObjectArea.Value=ObjectArea;
clearsmallnuclei.FunctionArgs.Image.FunctionInstance='FillHolesNuclearImages';
clearsmallnuclei.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,clearsmallnuclei);

combinenuclearandcytoplasmimages.InstanceName='CombineNuclearAndCytoplasmImages';
combinenuclearandcytoplasmimages.FunctionHandle=@combineImages;
combinenuclearandcytoplasmimages.FunctionArgs.CombineOperation.Value='AND';
combinenuclearandcytoplasmimages.FunctionArgs.Image1.FunctionInstance='ClearSmallNuclei';
combinenuclearandcytoplasmimages.FunctionArgs.Image1.OutputArg='Image';
combinenuclearandcytoplasmimages.FunctionArgs.Image2.FunctionInstance='ClearSmallCells';
combinenuclearandcytoplasmimages.FunctionArgs.Image2.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,combinenuclearandcytoplasmimages);

reconstructcytoplasmimage.InstanceName='ReconstructCytoplasmImage';
reconstructcytoplasmimage.FunctionHandle=@reconstructObjects;
reconstructcytoplasmimage.FunctionArgs.GuideImage.FunctionInstance='CombineNuclearAndCytoplasmImages';
reconstructcytoplasmimage.FunctionArgs.GuideImage.OutputArg='Image';
reconstructcytoplasmimage.FunctionArgs.ImageToReconstruct.FunctionInstance='ClearSmallNuclei';
reconstructcytoplasmimage.FunctionArgs.ImageToReconstruct.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,reconstructcytoplasmimage);

labelnuclei.InstanceName='LabelNuclei';
labelnuclei.FunctionHandle=@labelObjects;
labelnuclei.FunctionArgs.Image.FunctionInstance='ClearSmallNuclei';
labelnuclei.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,labelnuclei);

labelcytoplasm.InstanceName='LabelCytoplasm';
labelcytoplasm.FunctionHandle=@labelObjects;
labelcytoplasm.FunctionArgs.Image.FunctionInstance='ReconstructCytoplasmImage';
labelcytoplasm.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,labelcytoplasm);

getconvexobjects.InstanceName='GetConvexObjects';
getconvexobjects.FunctionHandle=@getConvexObjects;
getconvexobjects.FunctionArgs.ApproximationDistance.Value=ApproximationDistance;
getconvexobjects.FunctionArgs.Image.FunctionInstance='ClearSmallNuclei';
getconvexobjects.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,getconvexobjects);

distancewatershed.InstanceName='DistanceWatershed';
distancewatershed.FunctionHandle=@distanceWatershed;
distancewatershed.FunctionArgs.MedianFilterNhood.Value=MedianFilterSize;
distancewatershed.FunctionArgs.Image.FunctionInstance='ClearSmallNuclei';
distancewatershed.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,distancewatershed);

polygonalassistedwatershed.InstanceName='PolygonalAssistedWatershed';
polygonalassistedwatershed.FunctionHandle=@polygonalAssistedWatershed;
polygonalassistedwatershed.FunctionArgs.MinBlobArea.Value=ObjectArea;
polygonalassistedwatershed.FunctionArgs.ImageLabel.FunctionInstance='LabelNuclei';
polygonalassistedwatershed.FunctionArgs.ImageLabel.OutputArg='LabelMatrix';
polygonalassistedwatershed.FunctionArgs.WatershedLabel.FunctionInstance='DistanceWatershed';
polygonalassistedwatershed.FunctionArgs.WatershedLabel.OutputArg='LabelMatrix';
polygonalassistedwatershed.FunctionArgs.ConvexObjectsIndex.FunctionInstance='GetConvexObjects';
polygonalassistedwatershed.FunctionArgs.ConvexObjectsIndex.OutputArg='ConvexObjectsIndex';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,polygonalassistedwatershed);

segmentobjectsusingmarkers.InstanceName='SegmentObjectsUsingMarkers';
segmentobjectsusingmarkers.FunctionHandle=@segmentObjectsUsingMarkers;
segmentobjectsusingmarkers.FunctionArgs.MarkersLabel.FunctionInstance='PolygonalAssistedWatershed';
segmentobjectsusingmarkers.FunctionArgs.MarkersLabel.OutputArg='LabelMatrix';
segmentobjectsusingmarkers.FunctionArgs.ObjectsLabel.FunctionInstance='LabelCytoplasm';
segmentobjectsusingmarkers.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,segmentobjectsusingmarkers);

getpreviousframenr.InstanceName='GetPreviousFrameNr';
getpreviousframenr.FunctionHandle=@addFunction;
getpreviousframenr.FunctionArgs.Number2.Value=-1;
getpreviousframenr.FunctionArgs.Number1.FunctionInstance='SegmentationLoop';
getpreviousframenr.FunctionArgs.Number1.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,getpreviousframenr);

makelabelnames.InstanceName='MakeLabelNames';
makelabelnames.FunctionHandle=@makeImgFileName;
makelabelnames.FunctionArgs.FileBase.Value=SegmentationFilesRoot;
makelabelnames.FunctionArgs.NumberFmt.Value=NumberFormat;
makelabelnames.FunctionArgs.FileExt.Value='.mat';
makelabelnames.FunctionArgs.CurFrame.FunctionInstance='GetPreviousFrameNr';
makelabelnames.FunctionArgs.CurFrame.OutputArg='Sum';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,makelabelnames);

loadpreviouslabel.InstanceName='LoadPreviousLabel';
loadpreviouslabel.FunctionHandle=@loadCellsLabel;
loadpreviouslabel.FunctionArgs.FileName.FunctionInstance='MakeLabelNames';
loadpreviouslabel.FunctionArgs.FileName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,loadpreviouslabel);

resizepreviouslabel.InstanceName='ResizePreviousLabel';
resizepreviouslabel.FunctionHandle=@resizeImage;
resizepreviouslabel.FunctionArgs.Scale.Value=ResizeImageScale;
resizepreviouslabel.FunctionArgs.Method.Value='nearest';
resizepreviouslabel.FunctionArgs.Image.FunctionInstance='LoadPreviousLabel';
resizepreviouslabel.FunctionArgs.Image.OutputArg='LabelMatrix';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,resizepreviouslabel);

refinesegmentation.InstanceName='RefineSegmentation';
refinesegmentation.FunctionHandle=@refineSegmentation;
refinesegmentation.FunctionArgs.CurrentLabel.FunctionInstance='SegmentObjectsUsingMarkers';
refinesegmentation.FunctionArgs.CurrentLabel.OutputArg='LabelMatrix';
refinesegmentation.FunctionArgs.PreviousLabel.FunctionInstance='ResizePreviousLabel';
refinesegmentation.FunctionArgs.PreviousLabel.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,refinesegmentation);

reviewsegmentation.InstanceName='ReviewSegmentation';
reviewsegmentation.FunctionHandle=@manualSegmentationReview;
reviewsegmentation.FunctionArgs.ObjectsLabel.FunctionInstance='RefineSegmentation';
reviewsegmentation.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
reviewsegmentation.FunctionArgs.RawLabel.FunctionInstance='SegmentObjectsUsingMarkers';
reviewsegmentation.FunctionArgs.RawLabel.OutputArg='LabelMatrix';
reviewsegmentation.FunctionArgs.PreviousLabel.FunctionInstance='ResizePreviousLabel';
reviewsegmentation.FunctionArgs.PreviousLabel.OutputArg='Image';
reviewsegmentation.FunctionArgs.Image.FunctionInstance='ResizeImage';
reviewsegmentation.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,reviewsegmentation);

resizecytolabel.InstanceName='ResizeCytoLabel';
resizecytolabel.FunctionHandle=@resizeImage;
resizecytolabel.FunctionArgs.Scale.Value=ResizeLabelMatrixScale;
resizecytolabel.FunctionArgs.Method.Value='nearest';
resizecytolabel.FunctionArgs.Image.FunctionInstance='ReviewSegmentation';
resizecytolabel.FunctionArgs.Image.OutputArg='LabelMatrix';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,resizecytolabel);

savecellslabel.InstanceName='SaveCellsLabel';
savecellslabel.FunctionHandle=@saveCellsLabel;
savecellslabel.FunctionArgs.FileRoot.Value=SegmentationFilesRoot;
savecellslabel.FunctionArgs.NumberFormat.Value=NumberFormat;
savecellslabel.FunctionArgs.CellsLabel.FunctionInstance='ResizeCytoLabel';
savecellslabel.FunctionArgs.CellsLabel.OutputArg='Image';
savecellslabel.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
savecellslabel.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,savecellslabel);

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