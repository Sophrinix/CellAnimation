function []=pipelineCellCoverage(img_file_name)

dir_idx=strfind(img_file_name,'\');
dir_idx=dir_idx(end);
img_dir=img_file_name(1:dir_idx);
mask_file_name=[img_dir 'mask.mat'];

global functions_list;
functions_list=[];

read_image_function.InstanceName='ReadImage';
read_image_function.FunctionHandle=@readImage;

read_image_function.FunctionArgs.ImageName.Value=img_file_name;
read_image_function.FunctionArgs.ImageChannel.Value='';
functions_list=addToFunctionChain(functions_list,read_image_function);

normalize_image_to_16bit_function.InstanceName='NormalizeImageTo16Bit';
normalize_image_to_16bit_function.FunctionHandle=@imNorm;
normalize_image_to_16bit_function.FunctionArgs.RawImage.FunctionInstance='ReadImage';
normalize_image_to_16bit_function.FunctionArgs.RawImage.OutputArg='Image';
normalize_image_to_16bit_function.FunctionArgs.IntegerClass.Value='uint16';
functions_list=addToFunctionChain(functions_list,normalize_image_to_16bit_function);

display_normalized_image_function.InstanceName='DisplayNormalizedImage';
display_normalized_image_function.FunctionHandle=@displayImage;
display_normalized_image_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
display_normalized_image_function.FunctionArgs.Image.OutputArg='Image';
display_normalized_image_function.FunctionArgs.FigureNr.Value=1;
functions_list=addToFunctionChain(functions_list,display_normalized_image_function);

img2bw_function.InstanceName='ImageToBW';
img2bw_function.FunctionHandle=@im2bw_Wrapper;
img2bw_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
img2bw_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,img2bw_function);

negative_image_function.InstanceName='NegativeImage';
negative_image_function.FunctionHandle=@negativeImage;
negative_image_function.FunctionArgs.Image.FunctionInstance='ImageToBW';
negative_image_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,negative_image_function);

display_negative_image_function.InstanceName='DisplayNegativeImage';
display_negative_image_function.FunctionHandle=@displayImage;
display_negative_image_function.FunctionArgs.Image.FunctionInstance='NegativeImage';
display_negative_image_function.FunctionArgs.Image.OutputArg='Image';
display_negative_image_function.FunctionArgs.FigureNr.Value=2;
functions_list=addToFunctionChain(functions_list,display_negative_image_function);

label_objects_function.InstanceName='LabelObjects';
label_objects_function.FunctionHandle=@labelObjects;
label_objects_function.FunctionArgs.Image.FunctionInstance='NegativeImage';
label_objects_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,label_objects_function);

review_segmentation_function.InstanceName='ReviewSegmentation';
review_segmentation_function.FunctionHandle=@manualSegmentationReview;
review_segmentation_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelObjects';
review_segmentation_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.RawLabel.FunctionInstance='LabelObjects';
review_segmentation_function.FunctionArgs.RawLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.PreviousLabel.Value=[];
review_segmentation_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
review_segmentation_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,review_segmentation_function);

label_to_bw_function.InstanceName='LabelToBW';
label_to_bw_function.FunctionHandle=@compareValues;
label_to_bw_function.FunctionArgs.Operation.Value='>';
label_to_bw_function.FunctionArgs.Arg1.FunctionInstance='ReviewSegmentation';
label_to_bw_function.FunctionArgs.Arg1.OutputArg='LabelMatrix';
label_to_bw_function.FunctionArgs.Arg2.Value=0;
functions_list=addToFunctionChain(functions_list,label_to_bw_function);

save_bw_image_function.InstanceName='SaveBWImage';
save_bw_image_function.FunctionHandle=@saveWrapper;
save_bw_image_function.FunctionArgs.SaveData.FunctionInstance='LabelToBW';
save_bw_image_function.FunctionArgs.SaveData.OutputArg='BooleanOut';
save_bw_image_function.FunctionArgs.FileName.Value=mask_file_name;
functions_list=addToFunctionChain(functions_list,save_bw_image_function);

percentage_foreground_function.InstanceName='PercentageForeground';
percentage_foreground_function.FunctionHandle=@percentageForeground;
percentage_foreground_function.FunctionArgs.Image.FunctionInstance='LabelToBW';
percentage_foreground_function.FunctionArgs.Image.OutputArg='BooleanOut';
functions_list=addToFunctionChain(functions_list,percentage_foreground_function);

display_cell_coverage_function.InstanceName='DisplayCellCoverage';
display_cell_coverage_function.FunctionHandle=@displayVariable;
display_cell_coverage_function.FunctionArgs.VariableName.Value='Percentage of Cells';
display_cell_coverage_function.FunctionArgs.Variable.FunctionInstance='PercentageForeground';
display_cell_coverage_function.FunctionArgs.Variable.OutputArg='PercentageForeground';
functions_list=addToFunctionChain(functions_list,display_cell_coverage_function);

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();


%end pipelineCellCoverage
end