function []=assayBrightFieldSegComparisons()
%assay for testing different brightfield segmentation modules
TrackStruct=[];
ds='\'  %directory symbol
TrackStruct.DS=ds;

TrackStruct.NegligibleDistance=30; %distance below which distance ranking becomes unreliable
TrackStruct.NrParamsForSureMatch=6; %nr of params that need to match between a previous cell and an unidentified cell for a sure match
TrackStruct.MinPctDiff=0.1; %minimum significant difference bet two parameters (0-1)
TrackStruct.MinSecondDistance=5; % minimum distance the second cell has to be from the first to pick distance as most significant
TrackStruct.MaxAngleDiff=0.35; % radians - max difference between previous and current direction at which direction may still be most significant
TrackStruct.MaxDistRatio=0.6; %how close the first cell may be from the second cell and stiil have distance be most significant

TrackStruct.FrontParams=[2 3]; %include any params that should always be at the front in rankings here
TrackStruct.UnknownRankingOrder=[2 3 4 5 6 7 8 9 1];
TrackStruct.DistanceRankingOrder=[2 3 4 5 6 7 8 9 1];
TrackStruct.DirectionRankingOrder=[2 3 4 5 6 7 8 9 1];
% TrackStruct.DefaultParamWeights=[34 21 13 8 5 3 2 2 2];
% TrackStruct.UnknownParamWeights=[5 3 1 1 1 1 1 1 1];
TrackStruct.DefaultParamWeights=[3 2 0 0 0 0 0 0 0];
TrackStruct.UnknownParamWeights=[3 2 0 0 0 0 0 0 0];
%tracks grid layout
tracks_layout.TrackIDCol=1;
tracks_layout.TimeCol=2;
tracks_layout.Centroid1Col=3;
tracks_layout.Centroid2Col=4;
%always start shape params after centroid2col
tracks_layout.AreaCol=5; %area 3 gp
tracks_layout.EccCol=6; %eccentricity 4 bp
tracks_layout.MalCol=7; %major axis length 5 gp
tracks_layout.MilCol=8; %minor axis length 6 gp
tracks_layout.OriCol=9; %orientation 7
tracks_layout.PerCol=10; %perimeter 8
tracks_layout.SolCol=11; %solidity 9 bp
tracks_layout.BlobIDCol=12; %pixel blob id - used to get rid of oversegmentation
tracks_layout.MatchGroupIDCol=13; %matching group id - to determine which parameters to use when matching
TrackStruct.TracksLayout=tracks_layout;

%ancestry grid layout
ancestry_layout.TrackIDCol=1;
ancestry_layout.ParentIDCol=2;
ancestry_layout.GenerationCol=3;
ancestry_layout.StartTimeCol=4;
ancestry_layout.StopTimeCol=5;
TrackStruct.AncestryLayout=ancestry_layout;

%TrackStruct.SearchRadius=40; automatically determined right now
% TrackStruct.SearchRadius=20;
TrackStruct.Channel='';
TrackStruct.MinCytoArea=10;
TrackStruct.MinNuclArea=10;
TrackStruct.bContourLink=false;
TrackStruct.LinkDist=1;
TrackStruct.ObjectReduce=1;
TrackStruct.ClusterDist=20;
TrackStruct.bClearBorder=true;
TrackStruct.ApproxDist=2.5;
TrackStruct.ClearBorderDist=2;
TrackStruct.WatershedMed=5;
TrackStruct.MaxMergeDist=23;
TrackStruct.MaxSplitDist=45;
TrackStruct.MaxSplitArea=400;
TrackStruct.MinSplitEcc=0.5;
TrackStruct.MaxSplitEcc=0.95;
TrackStruct.MinTimeForSplit=900; %minutes

display_trackstruct_function.InstanceName='DisplayTrackStruct';
display_trackstruct_function.FunctionHandle=@displayVariable;
display_trackstruct_function.FunctionArgs.Variable.Value=TrackStruct;
display_trackstruct_function.FunctionArgs.VariableName.Value='TrackStruct';

%threshold images
global functions_list;

read_image_function.InstanceName='ReadImagesInSegmentationLoop';
read_image_function.FunctionHandle=@readImage;
read_image_function.FunctionArgs.ImageName.Value='C:\kam\Experiment-0002_Position(8)_t023.JPG';
read_image_function.FunctionArgs.ImageChannel.Value='';

normalize_image_to_16bit_function.InstanceName='NormalizeImageTo16Bit';
normalize_image_to_16bit_function.FunctionHandle=@imNorm;
normalize_image_to_16bit_function.FunctionArgs.RawImage.FunctionInstance='ReadImagesInSegmentationLoop';
normalize_image_to_16bit_function.FunctionArgs.RawImage.OutputArg='Image';
normalize_image_to_16bit_function.FunctionArgs.IntegerClass.Value='uint16';

resize_image_function.InstanceName='ResizeImage';
resize_image_function.FunctionHandle=@resizeImage;
resize_image_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
resize_image_function.FunctionArgs.Image.OutputArg='Image';
resize_image_function.FunctionArgs.Scale.Value=0.5;
resize_image_function.FunctionArgs.Method.Value='bicubic';

cyto_local_avg_filter_function.InstanceName='CytoGradientLocalFilter';
cyto_local_avg_filter_function.FunctionHandle=@generateBinImgUsingGradient;
cyto_local_avg_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
cyto_local_avg_filter_function.FunctionArgs.Image.OutputArg='Image';
cyto_local_avg_filter_function.FunctionArgs.GradientThreshold.Value=1500;
cyto_local_avg_filter_function.FunctionArgs.ClearBorder.Value=true;
cyto_local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=2;
fill_holes_cyto_images_function.InstanceName='FillHolesCytoplasmImages';
fill_holes_cyto_images_function.FunctionHandle=@fillHoles;
fill_holes_cyto_images_function.FunctionArgs.Image.FunctionInstance='CytoGradientLocalFilter';
fill_holes_cyto_images_function.FunctionArgs.Image.OutputArg='Image';
clear_small_cells_function.InstanceName='ClearSmallCells';
clear_small_cells_function.FunctionHandle=@clearSmallObjects;
clear_small_cells_function.FunctionArgs.Image.FunctionInstance='FillHolesCytoplasmImages';
clear_small_cells_function.FunctionArgs.Image.OutputArg='Image';
clear_small_cells_function.FunctionArgs.MinObjectArea.Value=TrackStruct.MinCytoArea;
nucl_local_avg_filter_function.InstanceName='NuclGradientLocalFilter';
nucl_local_avg_filter_function.FunctionHandle=@generateBinImgUsingGradient;
nucl_local_avg_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
nucl_local_avg_filter_function.FunctionArgs.Image.OutputArg='Image';
nucl_local_avg_filter_function.FunctionArgs.GradientThreshold.Value=1500;
nucl_local_avg_filter_function.FunctionArgs.ClearBorder.Value=true;
nucl_local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=2;
fill_holes_nucl_images_function.InstanceName='FillHolesNuclearImages';
fill_holes_nucl_images_function.FunctionHandle=@fillHoles;
fill_holes_nucl_images_function.FunctionArgs.Image.FunctionInstance='NuclGradientLocalFilter';
fill_holes_nucl_images_function.FunctionArgs.Image.OutputArg='Image';
clear_small_nuclei_function.InstanceName='ClearSmallNuclei';
clear_small_nuclei_function.FunctionHandle=@clearSmallObjects;
clear_small_nuclei_function.FunctionArgs.Image.FunctionInstance='FillHolesNuclearImages';
clear_small_nuclei_function.FunctionArgs.Image.OutputArg='Image';
clear_small_nuclei_function.FunctionArgs.MinObjectArea.Value=TrackStruct.MinNuclArea;
combine_nucl_plus_cyto_function.InstanceName='CombineNuclearAndCytoplasmImages';
combine_nucl_plus_cyto_function.FunctionHandle=@combineImages;
combine_nucl_plus_cyto_function.FunctionArgs.Image1.FunctionInstance='ClearSmallNuclei';
combine_nucl_plus_cyto_function.FunctionArgs.Image1.OutputArg='Image';
combine_nucl_plus_cyto_function.FunctionArgs.Image2.FunctionInstance='ClearSmallCells';
combine_nucl_plus_cyto_function.FunctionArgs.Image2.OutputArg='Image';
combine_nucl_plus_cyto_function.FunctionArgs.CombineOperation.Value='AND';
reconstruct_cyto_function.InstanceName='ReconstructCytoplasmImage';
reconstruct_cyto_function.FunctionHandle=@reconstructObjects;
reconstruct_cyto_function.FunctionArgs.GuideImage.FunctionInstance='CombineNuclearAndCytoplasmImages';
reconstruct_cyto_function.FunctionArgs.GuideImage.OutputArg='Image';
reconstruct_cyto_function.FunctionArgs.ImageToReconstruct.FunctionInstance='ClearSmallNuclei';
reconstruct_cyto_function.FunctionArgs.ImageToReconstruct.OutputArg='Image';
label_nuclei_function.InstanceName='LabelNuclei';
label_nuclei_function.FunctionHandle=@labelObjects;
label_nuclei_function.FunctionArgs.Image.FunctionInstance='ClearSmallNuclei';
label_nuclei_function.FunctionArgs.Image.OutputArg='Image';
label_cyto_function.InstanceName='LabelCytoplasm';
label_cyto_function.FunctionHandle=@labelObjects;
label_cyto_function.FunctionArgs.Image.FunctionInstance='ReconstructCytoplasmImage';
label_cyto_function.FunctionArgs.Image.OutputArg='Image';

%segment images
get_convex_objects_function.InstanceName='GetConvexObjects';
get_convex_objects_function.FunctionHandle=@getConvexObjects;
get_convex_objects_function.FunctionArgs.Image.FunctionInstance='ClearSmallNuclei';
get_convex_objects_function.FunctionArgs.Image.OutputArg='Image';
get_convex_objects_function.FunctionArgs.ApproximationDistance.Value=TrackStruct.ApproxDist;
distance_watershed_function.InstanceName='DistanceWatershed';
distance_watershed_function.FunctionHandle=@distanceWatershed;
distance_watershed_function.FunctionArgs.Image.FunctionInstance='ClearSmallNuclei';
distance_watershed_function.FunctionArgs.Image.OutputArg='Image';
distance_watershed_function.FunctionArgs.MedianFilterNhood.Value=TrackStruct.WatershedMed;
polygonal_assisted_watershed_function.InstanceName='PolygonalAssistedWatershed';
polygonal_assisted_watershed_function.FunctionHandle=@polygonalAssistedWatershed;
polygonal_assisted_watershed_function.FunctionArgs.ImageLabel.FunctionInstance='LabelNuclei';
polygonal_assisted_watershed_function.FunctionArgs.ImageLabel.OutputArg='LabelMatrix';
polygonal_assisted_watershed_function.FunctionArgs.WatershedLabel.FunctionInstance='DistanceWatershed';
polygonal_assisted_watershed_function.FunctionArgs.WatershedLabel.OutputArg='LabelMatrix';
polygonal_assisted_watershed_function.FunctionArgs.ConvexObjectsIndex.FunctionInstance='GetConvexObjects';
polygonal_assisted_watershed_function.FunctionArgs.ConvexObjectsIndex.OutputArg='ConvexObjectsIndex';
polygonal_assisted_watershed_function.FunctionArgs.MinBlobArea.Value=TrackStruct.MinNuclArea;

segment_objects_using_clusters_function.InstanceName='SegmentObjectsUsingClusters';
segment_objects_using_clusters_function.FunctionHandle=@segmentObjectsUsingClusters;
segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
segment_objects_using_clusters_function.FunctionArgs.ObjectReduce.Value=TrackStruct.ObjectReduce;
segment_objects_using_clusters_function.FunctionArgs.MinimumObjectArea.Value=TrackStruct.MinNuclArea;
segment_objects_using_clusters_function.FunctionArgs.ClusterDistance.Value=TrackStruct.ClusterDist;

segment_objects_using_markers_function.InstanceName='SegmentObjectsUsingMarkers';
segment_objects_using_markers_function.FunctionHandle=@segmentObjectsUsingMarkers;
segment_objects_using_markers_function.FunctionArgs.MarkersLabel.FunctionInstance='SegmentObjectsUsingClusters';
segment_objects_using_markers_function.FunctionArgs.MarkersLabel.OutputArg='LabelMatrix';
segment_objects_using_markers_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelCytoplasm';
segment_objects_using_markers_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
area_filter_function.InstanceName='AreaFilter';
area_filter_function.FunctionHandle=@areaFilterLabel;
area_filter_function.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentObjectsUsingMarkers';
area_filter_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
area_filter_function.FunctionArgs.MinArea.Value=TrackStruct.MinCytoArea;


resize_cyto_label_function.InstanceName='ResizeCytoLabel';
resize_cyto_label_function.FunctionHandle=@resizeImage;
resize_cyto_label_function.FunctionArgs.Image.FunctionInstance='AreaFilter';
resize_cyto_label_function.FunctionArgs.Image.OutputArg='LabelMatrix';
resize_cyto_label_function.FunctionArgs.Scale.Value=2;
resize_cyto_label_function.FunctionArgs.Method.Value='nearest';

show_label_function.InstanceName='ShowImage';
show_label_function.FunctionHandle=@showLabelMatrixAndPause;
show_label_function.FunctionArgs.FigureNr.Value=1;
show_label_function.FunctionArgs.LabelMatrix.FunctionInstance='ResizeCytoLabel';
show_label_function.FunctionArgs.LabelMatrix.OutputArg='Image';

functions_list=[{display_trackstruct_function};{read_image_function};...
    {normalize_image_to_16bit_function};{resize_image_function};{cyto_local_avg_filter_function};...
    {fill_holes_cyto_images_function};{clear_small_cells_function};{nucl_local_avg_filter_function};...
    {fill_holes_nucl_images_function};{clear_small_nuclei_function};{combine_nucl_plus_cyto_function};...
    {reconstruct_cyto_function};{label_nuclei_function};{label_cyto_function};{get_convex_objects_function};...    
    {distance_watershed_function};{polygonal_assisted_watershed_function};{segment_objects_using_clusters_function};{segment_objects_using_markers_function};{area_filter_function};...
    {resize_cyto_label_function};{show_label_function}];


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end function
end