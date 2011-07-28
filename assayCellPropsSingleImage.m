function []=assayCellPropsSingleImage(path_name)
%Usage
%This assay is used to segment objects in an image subject to manual review then extract their
%shape properties.
%
%Important Parameters
%path_name – The absolute image file name of the image to be analyzed.
%Other important parameters are those listed in the module section for the important modules
%listed below.
%
%Important Modules
%clearSmallObjects, distanceWatershed, generateBinImgUsingLocAvg,
%manualSegmentationReview, segmentObjectsUsingMarkers.

global functions_list;
functions_list=[];

get_file_function.InstanceName='GetFileInfo';
get_file_function.FunctionHandle=@getFileInfo;
get_file_function.FunctionArgs.DirSep.Value='\';
get_file_function.FunctionArgs.PathName.Value=path_name;
functions_list=addToFunctionChain(functions_list,get_file_function);

read_image_function.InstanceName='ReadImage';
read_image_function.FunctionHandle=@readImage;
read_image_function.FunctionArgs.ImageName.Value=path_name;
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

negative_image_function.InstanceName='NegativeImage';
negative_image_function.FunctionHandle=@imcomplementWrapper;
negative_image_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
negative_image_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,negative_image_function);

local_avg_filter_function.InstanceName='LocalAveragingFilter';
local_avg_filter_function.FunctionHandle=@generateBinImgUsingLocAvg;
local_avg_filter_function.FunctionArgs.Image.FunctionInstance='NegativeImage';
local_avg_filter_function.FunctionArgs.Image.OutputArg='Image';
local_avg_filter_function.FunctionArgs.Strel.Value='disk';
local_avg_filter_function.FunctionArgs.StrelSize.Value=10;
local_avg_filter_function.FunctionArgs.BrightnessThresholdPct.Value=1.2;
local_avg_filter_function.FunctionArgs.ClearBorder.Value=false;
local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=0;
functions_list=addToFunctionChain(functions_list,local_avg_filter_function);

fill_holes_function.InstanceName='FillHolesImage';
fill_holes_function.FunctionHandle=@fillHoles;
fill_holes_function.FunctionArgs.Image.FunctionInstance='LocalAveragingFilter';
fill_holes_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,fill_holes_function);

clear_small_objects_function.InstanceName='ClearSmallObjects';
clear_small_objects_function.FunctionHandle=@clearSmallObjects;
clear_small_objects_function.FunctionArgs.Image.FunctionInstance='FillHolesImage';
clear_small_objects_function.FunctionArgs.Image.OutputArg='Image';
clear_small_objects_function.FunctionArgs.MinObjectArea.Value=30;
functions_list=addToFunctionChain(functions_list,clear_small_objects_function);

display_thresholded_image_function.InstanceName='DisplayThresholdedImage';
display_thresholded_image_function.FunctionHandle=@displayImage;
display_thresholded_image_function.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
display_thresholded_image_function.FunctionArgs.Image.OutputArg='Image';
display_thresholded_image_function.FunctionArgs.FigureNr.Value=2;
functions_list=addToFunctionChain(functions_list,display_thresholded_image_function);

label_objects_function.InstanceName='LabelObjects';
label_objects_function.FunctionHandle=@labelObjects;
label_objects_function.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
label_objects_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,label_objects_function);

% segment_objects_using_clusters_function.InstanceName='SegmentObjectsUsingClusters';
% segment_objects_using_clusters_function.FunctionHandle=@segmentObjectsUsingClusters;
% segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelObjects';
% segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
% segment_objects_using_clusters_function.FunctionArgs.ObjectReduce.Value=1;
% segment_objects_using_clusters_function.FunctionArgs.MinimumObjectArea.Value=20;
% segment_objects_using_clusters_function.FunctionArgs.ClusterDistance.Value=5;
% functions_list=addToFunctionChain(functions_list,segment_objects_using_clusters_function);

distance_watershed_function.InstanceName='DistanceWatershed';
distance_watershed_function.FunctionHandle=@distanceWatershed;
distance_watershed_function.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
distance_watershed_function.FunctionArgs.Image.OutputArg='Image';
distance_watershed_function.FunctionArgs.MedianFilterNhood.Value=3;
functions_list=addToFunctionChain(functions_list,distance_watershed_function);

segment_objects_using_markers_function.InstanceName='SegmentObjectsUsingMarkers';
segment_objects_using_markers_function.FunctionHandle=@segmentObjectsUsingMarkers;
segment_objects_using_markers_function.FunctionArgs.MarkersLabel.FunctionInstance='DistanceWatershed';
segment_objects_using_markers_function.FunctionArgs.MarkersLabel.OutputArg='LabelMatrix';
segment_objects_using_markers_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelObjects';
segment_objects_using_markers_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,segment_objects_using_markers_function);

review_segmentation_function.InstanceName='ReviewSegmentation';
review_segmentation_function.FunctionHandle=@manualSegmentationReview;
review_segmentation_function.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentObjectsUsingMarkers';
review_segmentation_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.RawLabel.FunctionInstance='LabelObjects';
review_segmentation_function.FunctionArgs.RawLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.PreviousLabel.Value=[];
review_segmentation_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
review_segmentation_function.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,review_segmentation_function);

get_region_props_function.InstanceName='GetRegionProps';
get_region_props_function.FunctionHandle=@getRegionProps;
get_region_props_function.FunctionArgs.LabelMatrix.FunctionInstance='ReviewSegmentation';
get_region_props_function.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,get_region_props_function);

make_spreadsheet_file_name_function.InstanceName='MakeSpreadsheetFileName';
make_spreadsheet_file_name_function.FunctionHandle=@concatenateText;
make_spreadsheet_file_name_function.FunctionArgs.DirName.FunctionInstance='GetFileInfo';
make_spreadsheet_file_name_function.FunctionArgs.DirName.OutputArg='DirName';
make_spreadsheet_file_name_function.FunctionArgs.FileName.FunctionInstance='GetFileInfo';
make_spreadsheet_file_name_function.FunctionArgs.FileName.OutputArg='FileName';
make_spreadsheet_file_name_function.FunctionArgs.FileExt.Value='.csv';
functions_list=addToFunctionChain(functions_list,make_spreadsheet_file_name_function);


save_region_props_function.InstanceName='SaveRegionProps';
save_region_props_function.FunctionHandle=@saveRegionPropsSpreadsheets;
save_region_props_function.FunctionArgs.RegionProps.FunctionInstance='GetRegionProps';
save_region_props_function.FunctionArgs.RegionProps.OutputArg='RegionProps';
save_region_props_function.FunctionArgs.SpreadsheetFileName.FunctionInstance='MakeSpreadsheetFileName';
save_region_props_function.FunctionArgs.SpreadsheetFileName.OutputArg='Text';
functions_list=addToFunctionChain(functions_list,save_region_props_function);

make_label_file_name_function.InstanceName='MakeLabelFileName';
make_label_file_name_function.FunctionHandle=@concatenateText;
make_label_file_name_function.FunctionArgs.DirName.FunctionInstance='GetFileInfo';
make_label_file_name_function.FunctionArgs.DirName.OutputArg='DirName';
make_label_file_name_function.FunctionArgs.FileName.FunctionInstance='GetFileInfo';
make_label_file_name_function.FunctionArgs.FileName.OutputArg='FileName';
make_label_file_name_function.FunctionArgs.FileExt.Value='.mat';
functions_list=addToFunctionChain(functions_list,make_label_file_name_function);

save_label_function.InstanceName='SaveLabel';
save_label_function.FunctionHandle=@saveWrapper;
save_label_function.FunctionArgs.SaveData.FunctionInstance='ReviewSegmentation';
save_label_function.FunctionArgs.SaveData.OutputArg='LabelMatrix';
save_label_function.FunctionArgs.FileName.FunctionInstance='MakeLabelFileName';
save_label_function.FunctionArgs.FileName.OutputArg='Text';
functions_list=addToFunctionChain(functions_list,save_label_function);

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();


%end pipelineCellCoverage
end
