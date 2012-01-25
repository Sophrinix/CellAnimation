function []=assayCellCoverage()
%assayCellCoverage - This assay is used to determine what percentage of an image is occupied 
% by objects.  ImageFileName - String variable specifying the absolute image file name 
%of  the image to be  analyzed. ImageDirectory - String variable specifying the 
%directory where  the image to be analyzed is located. MaskFileName - String variable 
%specifying the file  name of the resulting binary image from which  the 
%object percentage is calculated.  Important Modules - manualSegmentationReview.

global functions_list;
functions_list=[];
%script variables
ImageFileName='C:/walter/20071104/20071104 ha ht-1080 af488coll4 10ugperml  then af488coll4 1ugperml milk 35 mm bac pd_t001.TIF';
ImageDirectory='C:/walter/20071104/';
MaskFileName=[ImageDirectory 'mask.mat'];
%end script variables


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

imagetobw.InstanceName='ImageToBW';
imagetobw.FunctionHandle=@im2bw_Wrapper;
imagetobw.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
imagetobw.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,imagetobw);

negativeimage.InstanceName='NegativeImage';
negativeimage.FunctionHandle=@negativeImage;
negativeimage.FunctionArgs.Image.FunctionInstance='ImageToBW';
negativeimage.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,negativeimage);

displaynegativeimage.InstanceName='DisplayNegativeImage';
displaynegativeimage.FunctionHandle=@displayImage;
displaynegativeimage.FunctionArgs.FigureNr.Value=2;
displaynegativeimage.FunctionArgs.Image.FunctionInstance='NegativeImage';
displaynegativeimage.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,displaynegativeimage);

labelobjects.InstanceName='LabelObjects';
labelobjects.FunctionHandle=@labelObjects;
labelobjects.FunctionArgs.Image.FunctionInstance='NegativeImage';
labelobjects.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,labelobjects);

reviewsegmentation.InstanceName='ReviewSegmentation';
reviewsegmentation.FunctionHandle=@manualSegmentationReview;
reviewsegmentation.FunctionArgs.PreviousLabel.Value=[];
reviewsegmentation.FunctionArgs.ObjectsLabel.FunctionInstance='LabelObjects';
reviewsegmentation.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
reviewsegmentation.FunctionArgs.RawLabel.FunctionInstance='LabelObjects';
reviewsegmentation.FunctionArgs.RawLabel.OutputArg='LabelMatrix';
reviewsegmentation.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
reviewsegmentation.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,reviewsegmentation);

labeltobw.InstanceName='LabelToBW';
labeltobw.FunctionHandle=@compareValues;
labeltobw.FunctionArgs.Operation.Value='>';
labeltobw.FunctionArgs.Arg2.Value=0;
labeltobw.FunctionArgs.Arg1.FunctionInstance='ReviewSegmentation';
labeltobw.FunctionArgs.Arg1.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,labeltobw);

savebwimage.InstanceName='SaveBWImage';
savebwimage.FunctionHandle=@saveWrapper;
savebwimage.FunctionArgs.FileName.Value=MaskFileName;
savebwimage.FunctionArgs.SaveData.FunctionInstance='LabelToBW';
savebwimage.FunctionArgs.SaveData.OutputArg='BooleanOut';
functions_list=addToFunctionChain(functions_list,savebwimage);

percentageforeground.InstanceName='PercentageForeground';
percentageforeground.FunctionHandle=@percentageForeground;
percentageforeground.FunctionArgs.Image.FunctionInstance='LabelToBW';
percentageforeground.FunctionArgs.Image.OutputArg='BooleanOut';
functions_list=addToFunctionChain(functions_list,percentageforeground);

displaycellcoverage.InstanceName='DisplayCellCoverage';
displaycellcoverage.FunctionHandle=@displayVariable;
displaycellcoverage.FunctionArgs.VariableName.Value='Percentage of Cells';
displaycellcoverage.FunctionArgs.Variable.FunctionInstance='PercentageForeground';
displaycellcoverage.FunctionArgs.Variable.OutputArg='PercentageForeground';
functions_list=addToFunctionChain(functions_list,displaycellcoverage);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end