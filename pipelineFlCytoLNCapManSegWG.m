function []=pipelineFlCytoLNCapManSegWG(well_folder)
TrackStruct=[];
TrackStruct.ImgExt='.tif';
ds='\'  %directory symbol
TrackStruct.DS=ds;
root_folder='i:\walter';
TrackStruct.ImageFileName='Cell Tracker Green - Confocal - n';
%low hepsin expressing - not really wildtype
TrackStruct.ImageFileBase=[well_folder ds TrackStruct.ImageFileName];
%hepsin overexpressing
% TrackStruct.ImageFileBase=[well_folder ds 'llh_hep_lm7_t'];
TrackStruct.StartFrame=13;
TrackStruct.FrameCount=48;
TrackStruct.TimeFrame=8; %minutes
TrackStruct.FrameStep=1; %read every x frames
TrackStruct.NumberFormat='%06d';
TrackStruct.MaxFramesMissing=6; %how many frames a cell can disappear before we end its track
TrackStruct.FrontParams=[];


name_idx=find(well_folder==ds,2,'last');
%generate a unique well name
well_name=well_folder((name_idx(1)+1):end);
well_name(name_idx(2)-name_idx(1))=[];
well_name(well_name==' ')=[];
TrackStruct.OutputFolder=[root_folder ds 'output' ds well_name];
track_dir=[TrackStruct.OutputFolder ds 'track'];
TrackStruct.TrackDir=track_dir;
mkdir(track_dir);
TrackStruct.SegFileRoot=[track_dir ds 'grayscale'];
TrackStruct.TracksFile=[track_dir ds 'tracks.mat'];
TrackStruct.ShapesFile=[track_dir ds 'shapes.mat'];
TrackStruct.RankFile=[track_dir ds 'ranks.mat'];
prol_dir=[TrackStruct.OutputFolder ds 'proliferation'];
TrackStruct.ProlDir=prol_dir;
mkdir(prol_dir);
TrackStruct.ProlFileRoot=[prol_dir ds 'prol'];
xls_folder=[root_folder ds 'spreadsheets'];
mkdir(xls_folder);
TrackStruct.ProlXlsFile=[xls_folder ds well_name '.csv'];
TrackStruct.ShapesXlsFile=[xls_folder ds well_name '_shapes.csv'];
TrackStruct.NegligibleDistance=30; %distance below which distance ranking becomes unreliable
TrackStruct.NrParamsForSureMatch=6; %nr of params that need to match between a previous cell and an unidentified cell for a sure match
TrackStruct.MinPctDiff=0.1; %minimum significant difference bet two parameters (0-1)
TrackStruct.MinSecondDistance=5; % minimum distance the second cell has to be from the first to pick distance as most significant
TrackStruct.MaxAngleDiff=0.35; % radians - max difference between previous and current direction at which direction may still be most significant
TrackStruct.MaxDistRatio=0.6; %how close the first cell may be from the second cell and stiil have distance be most significant

TrackStruct.UnknownRankingOrder=[1 2 3 4 5 6 7 8 9];
TrackStruct.DistanceRankingOrder=[1 3 4 5 6 7 8 9 2];
TrackStruct.DirectionRankingOrder=[2 3 4 5 6 7 8 9 1];
TrackStruct.DefaultParamWeights=[34 21 13 8 5 3 2 2 2];
TrackStruct.UnknownParamWeights=[5 3 1 1 1 1 1 1 1];
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
TrackStruct.MinCytoArea=30;
TrackStruct.MinNuclArea=30;
TrackStruct.bContourLink=false;
TrackStruct.LinkDist=1;
TrackStruct.ObjectReduce=1;
TrackStruct.ClusterDist=20;
TrackStruct.bClearBorder=false;
TrackStruct.ApproxDist=2.4;
TrackStruct.ClearBorderDist=0;
TrackStruct.WatershedMed=2;
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
image_read_loop.InstanceName='SegmentationLoop';
image_read_loop.FunctionHandle=@forLoop;
image_read_loop.FunctionArgs.StartLoop.Value=TrackStruct.StartFrame;
image_read_loop.FunctionArgs.EndLoop.Value=(TrackStruct.StartFrame+TrackStruct.FrameCount-1)*TrackStruct.FrameStep;
image_read_loop.FunctionArgs.IncrementLoop.Value=TrackStruct.FrameStep;
image_read_loop.FunctionArgs.MatchingGroups.Value=[]; %need to add another provider
image_read_loop.FunctionArgs.MatchingGroups.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.FunctionArgs.MatchingGroups.OutputArg='MatchingGroups';
image_read_loop.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.FunctionArgs.Tracks.OutputArg='Tracks';
image_read_loop.FunctionArgs.Tracks.Value=[];

display_curtrackframe_function.InstanceName='DisplayCurFrame';
display_curtrackframe_function.FunctionHandle=@displayVariable;
display_curtrackframe_function.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
display_curtrackframe_function.FunctionArgs.Variable.OutputArg='LoopCounter';
display_curtrackframe_function.FunctionArgs.VariableName.Value='Current Tracking Frame';

make_file_name_function.InstanceName='MakeImageNamesInSegmentationLoop';
make_file_name_function.FunctionHandle=@makeImgFileName;
make_file_name_function.FunctionArgs.FileBase.Value=TrackStruct.ImageFileBase;
make_file_name_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
make_file_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_file_name_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_file_name_function.FunctionArgs.FileExt.Value=TrackStruct.ImgExt;
read_image_function.InstanceName='ReadImagesInSegmentationLoop';
read_image_function.FunctionHandle=@readImage;
read_image_function.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInSegmentationLoop';
read_image_function.FunctionArgs.ImageName.OutputArg='FileName';
read_image_function.FunctionArgs.ImageChannel.Value='';
normalize_image_to_16bit_function.InstanceName='NormalizeImageTo16Bit';
normalize_image_to_16bit_function.FunctionHandle=@imNorm;
normalize_image_to_16bit_function.FunctionArgs.RawImage.FunctionInstance='ReadImagesInSegmentationLoop';
normalize_image_to_16bit_function.FunctionArgs.RawImage.OutputArg='Image';
normalize_image_to_16bit_function.FunctionArgs.IntegerClass.Value='uint16';

% gaussian_pyramid_function.InstanceName='GaussianPyramid';
% gaussian_pyramid_function.FunctionHandle=@gaussianPyramid;
% gaussian_pyramid_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
% gaussian_pyramid_function.FunctionArgs.Image.OutputArg='Image';
resize_image_function.InstanceName='ResizeImage';
resize_image_function.FunctionHandle=@resizeImage;
resize_image_function.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
resize_image_function.FunctionArgs.Image.OutputArg='Image';
resize_image_function.FunctionArgs.Scale.Value=0.5;
resize_image_function.FunctionArgs.Method.Value='bicubic';
cyto_local_avg_filter_function.InstanceName='CytoBrightnessLocalAveragingFilter';
cyto_local_avg_filter_function.FunctionHandle=@generateBinImgUsingLocAvg;
cyto_local_avg_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
cyto_local_avg_filter_function.FunctionArgs.Image.OutputArg='Image';
cyto_local_avg_filter_function.FunctionArgs.Strel.Value='disk';
cyto_local_avg_filter_function.FunctionArgs.StrelSize.Value=10;
cyto_local_avg_filter_function.FunctionArgs.BrightnessThresholdPct.Value=1.1;
cyto_local_avg_filter_function.FunctionArgs.ClearBorder.Value=false;
cyto_local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=0;
% cyto_global_int_filter_function.InstanceName='CytoGlobalBrightnessIntensityFilter';
% cyto_global_int_filter_function.FunctionHandle=@generateBinImgUsingGlobInt;
% cyto_global_int_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
% cyto_global_int_filter_function.FunctionArgs.Image.OutputArg='Image';
% cyto_global_int_filter_function.FunctionArgs.IntensityThresholdPct.Value=0.1;
% cyto_global_int_filter_function.FunctionArgs.ClearBorder.Value=true;
% cyto_global_int_filter_function.FunctionArgs.ClearBorderDist.Value=2;
% combine_cyto_images_function.InstanceName='CombineCytoplasmImages';
% combine_cyto_images_function.FunctionHandle=@combineImages;
% combine_cyto_images_function.FunctionArgs.Image1.FunctionInstance='CytoBrightnessLocalAveragingFilter';
% combine_cyto_images_function.FunctionArgs.Image1.OutputArg='Image';
% combine_cyto_images_function.FunctionArgs.Image2.FunctionInstance='CytoGlobalBrightnessIntensityFilter';
% combine_cyto_images_function.FunctionArgs.Image2.OutputArg='Image';
% combine_cyto_images_function.FunctionArgs.CombineOperation.Value='OR';
fill_holes_cyto_images_function.InstanceName='FillHolesCytoplasmImages';
fill_holes_cyto_images_function.FunctionHandle=@fillHoles;
fill_holes_cyto_images_function.FunctionArgs.Image.FunctionInstance='CytoBrightnessLocalAveragingFilter';
fill_holes_cyto_images_function.FunctionArgs.Image.OutputArg='Image';
clear_small_cells_function.InstanceName='ClearSmallCells';
clear_small_cells_function.FunctionHandle=@clearSmallObjects;
clear_small_cells_function.FunctionArgs.Image.FunctionInstance='FillHolesCytoplasmImages';
clear_small_cells_function.FunctionArgs.Image.OutputArg='Image';
clear_small_cells_function.FunctionArgs.MinObjectArea.Value=TrackStruct.MinCytoArea;
nucl_local_avg_filter_function.InstanceName='NuclBrightnessLocalAveragingFilter';
nucl_local_avg_filter_function.FunctionHandle=@generateBinImgUsingLocAvg;
nucl_local_avg_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
nucl_local_avg_filter_function.FunctionArgs.Image.OutputArg='Image';
nucl_local_avg_filter_function.FunctionArgs.Strel.Value='disk';
nucl_local_avg_filter_function.FunctionArgs.StrelSize.Value=10;
nucl_local_avg_filter_function.FunctionArgs.BrightnessThresholdPct.Value=1.1;
nucl_local_avg_filter_function.FunctionArgs.ClearBorder.Value=false;
nucl_local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=0;
% nucl_global_int_filter_function.InstanceName='NuclGlobalBrightnessIntensityFilter';
% nucl_global_int_filter_function.FunctionHandle=@generateBinImgUsingGlobInt;
% nucl_global_int_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
% nucl_global_int_filter_function.FunctionArgs.Image.OutputArg='Image';
% nucl_global_int_filter_function.FunctionArgs.IntensityThresholdPct.Value=0.1;
% nucl_global_int_filter_function.FunctionArgs.ClearBorder.Value=true;
% nucl_global_int_filter_function.FunctionArgs.ClearBorderDist.Value=2;
% combine_nucl_images_function.InstanceName='CombineNuclearImages';
% combine_nucl_images_function.FunctionHandle=@combineImages;
% combine_nucl_images_function.FunctionArgs.Image1.FunctionInstance='CytoBrightnessLocalAveragingFilter';
% combine_nucl_images_function.FunctionArgs.Image1.OutputArg='Image';
% combine_nucl_images_function.FunctionArgs.Image2.FunctionInstance='CytoGlobalBrightnessIntensityFilter';
% combine_nucl_images_function.FunctionArgs.Image2.OutputArg='Image';
% combine_nucl_images_function.FunctionArgs.CombineOperation.Value='OR';
fill_holes_nucl_images_function.InstanceName='FillHolesNuclearImages';
fill_holes_nucl_images_function.FunctionHandle=@fillHoles;
fill_holes_nucl_images_function.FunctionArgs.Image.FunctionInstance='NuclBrightnessLocalAveragingFilter';
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
polygonal_assisted_watershed_function.FunctionArgs.WatershedLabel.OutputArg='WatershedLabel';
polygonal_assisted_watershed_function.FunctionArgs.ConvexObjectsIndex.FunctionInstance='GetConvexObjects';
polygonal_assisted_watershed_function.FunctionArgs.ConvexObjectsIndex.OutputArg='ConvexObjectsIndex';
polygonal_assisted_watershed_function.FunctionArgs.MinBlobArea.Value=TrackStruct.MinNuclArea;

segment_objects_using_markers_function.InstanceName='SegmentObjectsUsingMarkers';
segment_objects_using_markers_function.FunctionHandle=@segmentObjectsUsingMarkers;
segment_objects_using_markers_function.FunctionArgs.MarkersLabel.FunctionInstance='PolygonalAssistedWatershed';
segment_objects_using_markers_function.FunctionArgs.MarkersLabel.OutputArg='LabelMatrix';
segment_objects_using_markers_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelCytoplasm';
segment_objects_using_markers_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';

% segment_objects_using_clusters_function.InstanceName='SegmentObjectsUsingClusters';
% segment_objects_using_clusters_function.FunctionHandle=@segmentObjectsUsingClusters;
% segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
% segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
% segment_objects_using_clusters_function.FunctionArgs.ObjectReduce.Value=TrackStruct.ObjectReduce;
% segment_objects_using_clusters_function.FunctionArgs.MinimumObjectArea.Value=TrackStruct.MinNuclArea;
% segment_objects_using_clusters_function.FunctionArgs.ClusterDistance.Value=TrackStruct.ClusterDist;

review_segmentation_function.InstanceName='ReviewSegmentation';
review_segmentation_function.FunctionHandle=@manualSegmentationReview;
review_segmentation_function.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentObjectsUsingMarkers';
review_segmentation_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';


resize_cyto_label_function.InstanceName='ResizeCytoLabel';
resize_cyto_label_function.FunctionHandle=@resizeImage;
resize_cyto_label_function.FunctionArgs.Image.FunctionInstance='ReviewSegmentation';
resize_cyto_label_function.FunctionArgs.Image.OutputArg='LabelMatrix';
resize_cyto_label_function.FunctionArgs.Scale.Value=2;
resize_cyto_label_function.FunctionArgs.Method.Value='nearest';

save_cells_label_function.InstanceName='SaveCellsLabel';
save_cells_label_function.FunctionHandle=@saveCellsLabel;
save_cells_label_function.FunctionArgs.CellsLabel.FunctionInstance='ResizeCytoLabel';
save_cells_label_function.FunctionArgs.CellsLabel.OutputArg='Image';
save_cells_label_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
save_cells_label_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
save_cells_label_function.FunctionArgs.FileRoot.Value=TrackStruct.SegFileRoot;
save_cells_label_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberFormat;

image_read_loop.LoopFunctions=[{display_curtrackframe_function};{make_file_name_function};{read_image_function};...
    {normalize_image_to_16bit_function};{resize_image_function};{cyto_local_avg_filter_function};...
    {fill_holes_cyto_images_function};{clear_small_cells_function};{nucl_local_avg_filter_function};...
    {fill_holes_nucl_images_function};{clear_small_nuclei_function};{get_convex_objects_function};{distance_watershed_function};...
    {combine_nucl_plus_cyto_function};{reconstruct_cyto_function};{label_nuclei_function};{label_cyto_function};...
    {polygonal_assisted_watershed_function};{segment_objects_using_markers_function};{review_segmentation_function};...
    {resize_cyto_label_function};{save_cells_label_function}];


functions_list=[{display_trackstruct_function};{image_read_loop}];

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end function
end