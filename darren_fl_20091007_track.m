function []=darren_fl_20091007_track(well_folder)
TrackStruct=[];
TrackStruct.ImgExt='.tif';
ds='\'  %directory symbol
TrackStruct.DS=ds;
root_folder='i:\darren';
TrackStruct.ImageFileName='DsRed - Confocal - n';
%low hepsin expressing - not really wildtype
TrackStruct.ImageFileBase=[well_folder ds TrackStruct.ImageFileName];
%hepsin overexpressing
% TrackStruct.ImageFileBase=[well_folder ds 'llh_hep_lm7_t'];
TrackStruct.StartFrame=1;
TrackStruct.FrameCount=646;
TrackStruct.TimeFrame=6; %minutes
TrackStruct.FrameStep=1; %read every x frames
TrackStruct.NumberFormat='%06d';
TrackStruct.MaxFramesMissing=6; %how many frames a cell can disappear before we end its track


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
tracks_layout.AreaCol=5; %area
tracks_layout.EccCol=6; %eccentricity
tracks_layout.MalCol=7; %major axis length
tracks_layout.MilCol=8; %minor axis length
tracks_layout.OriCol=9; %orientation
tracks_layout.PerCol=10; %perimeter
tracks_layout.SolCol=11; %solidity
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
TrackStruct.ObjectReduce=0.3;
TrackStruct.ClusterDist=5;
TrackStruct.bClearBorder=true;
TrackStruct.ApproxDist=2;
TrackStruct.ClearBorderDist=2;
TrackStruct.WatershedMed=3;
TrackStruct.MaxMergeDist=20;
TrackStruct.MaxSplitDist=45;
TrackStruct.MaxSplitArea=500;
TrackStruct.MinSplitEcc=0.6;
TrackStruct.MaxSplitEcc=0.9;

display_trackstruct_function.InstanceName='DisplayTrackStruct';
display_trackstruct_function.FunctionHandle=@displayVariable;
display_trackstruct_function.FunctionArgs.Variable.Value=TrackStruct;
display_trackstruct_function.FunctionArgs.VariableName.Value='TrackStruct';
%threshold images
global functions_list;
loop_args.StartLoop=TrackStruct.StartFrame;
image_read_loop.InstanceName='SegmentationLoop';
image_read_loop.FunctionHandle=@forLoop;
image_read_loop.FunctionArgs.StartLoop.Value=TrackStruct.StartFrame;
image_read_loop.FunctionArgs.EndLoop.Value=(TrackStruct.StartFrame+TrackStruct.FrameCount-1)*TrackStruct.FrameStep;
image_read_loop.FunctionArgs.IncrementLoop.Value=1;
image_read_loop.FunctionArgs.MatchingGroups.Value=[]; %need to add another provider
image_read_loop.FunctionArgs.MatchingGroups.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.FunctionArgs.MatchingGroups.OutputArg='MatchingGroups';
image_read_loop.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.FunctionArgs.Tracks.OutputArg='Tracks';
image_read_loop.FunctionArgs.Tracks.Value=[];
image_read_loop.KeepValues.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.KeepValues.Tracks.OutputArg='Tracks';
image_read_loop.KeepValues.MatchingGroups.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.KeepValues.MatchingGroups.OutputArg='MatchingGroups';

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
cyto_local_avg_filter_function.FunctionArgs.ClearBorder.Value=true;
cyto_local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=2;
cyto_global_int_filter_function.InstanceName='CytoGlobalBrightnessIntensityFilter';
cyto_global_int_filter_function.FunctionHandle=@generateBinImgUsingGlobInt;
cyto_global_int_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
cyto_global_int_filter_function.FunctionArgs.Image.OutputArg='Image';
cyto_global_int_filter_function.FunctionArgs.IntensityThresholdPct.Value=0.1;
cyto_global_int_filter_function.FunctionArgs.ClearBorder.Value=true;
cyto_global_int_filter_function.FunctionArgs.ClearBorderDist.Value=2;
combine_cyto_images_function.InstanceName='CombineCytoplasmImages';
combine_cyto_images_function.FunctionHandle=@combineImages;
combine_cyto_images_function.FunctionArgs.Image1.FunctionInstance='CytoBrightnessLocalAveragingFilter';
combine_cyto_images_function.FunctionArgs.Image1.OutputArg='Image';
combine_cyto_images_function.FunctionArgs.Image2.FunctionInstance='CytoGlobalBrightnessIntensityFilter';
combine_cyto_images_function.FunctionArgs.Image2.OutputArg='Image';
combine_cyto_images_function.FunctionArgs.CombineOperation.Value='OR';
fill_holes_cyto_images_function.InstanceName='FillHolesCytoplasmImages';
fill_holes_cyto_images_function.FunctionHandle=@fillHoles;
fill_holes_cyto_images_function.FunctionArgs.Image.FunctionInstance='CombineCytoplasmImages';
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
nucl_local_avg_filter_function.FunctionArgs.ClearBorder.Value=true;
nucl_local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=2;
nucl_global_int_filter_function.InstanceName='NuclGlobalBrightnessIntensityFilter';
nucl_global_int_filter_function.FunctionHandle=@generateBinImgUsingGlobInt;
nucl_global_int_filter_function.FunctionArgs.Image.FunctionInstance='ResizeImage';
nucl_global_int_filter_function.FunctionArgs.Image.OutputArg='Image';
nucl_global_int_filter_function.FunctionArgs.IntensityThresholdPct.Value=0.1;
nucl_global_int_filter_function.FunctionArgs.ClearBorder.Value=true;
nucl_global_int_filter_function.FunctionArgs.ClearBorderDist.Value=2;
combine_nucl_images_function.InstanceName='CombineNuclearImages';
combine_nucl_images_function.FunctionHandle=@combineImages;
combine_nucl_images_function.FunctionArgs.Image1.FunctionInstance='CytoBrightnessLocalAveragingFilter';
combine_nucl_images_function.FunctionArgs.Image1.OutputArg='Image';
combine_nucl_images_function.FunctionArgs.Image2.FunctionInstance='CytoGlobalBrightnessIntensityFilter';
combine_nucl_images_function.FunctionArgs.Image2.OutputArg='Image';
combine_nucl_images_function.FunctionArgs.CombineOperation.Value='OR';
fill_holes_nucl_images_function.InstanceName='FillHolesNuclearImages';
fill_holes_nucl_images_function.FunctionHandle=@fillHoles;
fill_holes_nucl_images_function.FunctionArgs.Image.FunctionInstance='CombineNuclearImages';
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
reconstruct_cyto_function.FunctionArgs.ImageToReconstruct.FunctionInstance='ClearSmallCells';
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
clear_small_components_function.InstanceName='ClearSmallComponents';
clear_small_components_function.FunctionHandle=@clearSmallComponentsInLabelMatrix;
clear_small_components_function.FunctionArgs.LabelMatrix.FunctionInstance='SegmentObjectsUsingMarkers';
clear_small_components_function.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
clear_small_components_function.FunctionArgs.MinComponentArea.Value=TrackStruct.MinCytoArea;
resize_cyto_label_function.InstanceName='ResizeCytoLabel';
resize_cyto_label_function.FunctionHandle=@resizeImage;
resize_cyto_label_function.FunctionArgs.Image.FunctionInstance='ClearSmallComponents';
resize_cyto_label_function.FunctionArgs.Image.OutputArg='LabelMatrix';
resize_cyto_label_function.FunctionArgs.Scale.Value=2;
resize_cyto_label_function.FunctionArgs.Method.Value='nearest';

%tracking
if_is_empty_cells_label_function.InstanceName='IfIsEmptyPreviousCellsLabel';
if_is_empty_cells_label_function.FunctionHandle=@if_statement;
if_is_empty_cells_label_function.FunctionArgs.TestResult.FunctionInstance='IsEmptyPreviousCellsLabel';
if_is_empty_cells_label_function.FunctionArgs.TestResult.OutputArg='Boolean';
if_is_empty_cells_label_function.FunctionArgs.CellsLabel.FunctionInstance='ResizeCytoLabel';
if_is_empty_cells_label_function.FunctionArgs.CellsLabel.OutputArg='Image';
if_is_empty_cells_label_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
if_is_empty_cells_label_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
if_is_empty_cells_label_function.FunctionArgs.PreviousCellsLabel.FunctionInstance='StartTracks';
if_is_empty_cells_label_function.FunctionArgs.PreviousCellsLabel.OutputArg='CellsLabel';
if_is_empty_cells_label_function.FunctionArgs.PreviousCellsLabel.Value=[];
if_is_empty_cells_label_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
if_is_empty_cells_label_function.FunctionArgs.Tracks.OutputArg='Tracks';
if_is_empty_cells_label_function.FunctionArgs.Tracks.Value=[];
if_is_empty_cells_label_function.FunctionArgs.MatchingGroups.FunctionInstance='SegmentationLoop';
if_is_empty_cells_label_function.FunctionArgs.MatchingGroups.InputArg='MatchingGroups';
if_is_empty_cells_label_function.FunctionArgs.TrackAssignments.Value=[];
if_is_empty_cells_label_function.TestFunction.InstanceName='IsEmptyPreviousCellsLabel';
if_is_empty_cells_label_function.TestFunction.FunctionHandle=@isEmptyFunction;
if_is_empty_cells_label_function.TestFunction.FunctionArgs.TestVariable.FunctionInstance='IfIsEmptyPreviousCellsLabel';
if_is_empty_cells_label_function.TestFunction.FunctionArgs.TestVariable.InputArg='PreviousCellsLabel'; %only works for subfunctions
if_is_empty_cells_label_function.TestFunction.FunctionArgs.PreviousCellsLabel.Value=[];
if_is_empty_cells_label_function.KeepValues.Tracks.FunctionInstance='StartTracks';
if_is_empty_cells_label_function.KeepValues.Tracks.OutputArg='Tracks';
if_is_empty_cells_label_function.KeepValues.Tracks.FunctionInstance2='ContinueTracks';
if_is_empty_cells_label_function.KeepValues.Tracks.OutputArg2='Tracks';
if_is_empty_cells_label_function.KeepValues.NewTracks.FunctionInstance='StartTracks';
if_is_empty_cells_label_function.KeepValues.NewTracks.OutputArg='Tracks';
if_is_empty_cells_label_function.KeepValues.NewTracks.FunctionInstance2='ContinueTracks';
if_is_empty_cells_label_function.KeepValues.NewTracks.OutputArg2='NewTracks';
if_is_empty_cells_label_function.KeepValues.MatchingGroups.FunctionInstance='StartTracks';
if_is_empty_cells_label_function.KeepValues.MatchingGroups.OutputArg='MatchingGroups';
if_is_empty_cells_label_function.KeepValues.MatchingGroups.FunctionInstance2='AssignCellsToTracksLoop';
if_is_empty_cells_label_function.KeepValues.MatchingGroups.OutputArg2='MatchingGroups';



get_shape_params_function.InstanceName='GetShapeParameters';
get_shape_params_function.FunctionHandle=@getShapeParams;
get_shape_params_function.FunctionArgs.LabelMatrix.FunctionInstance='IfIsEmptyPreviousCellsLabel';
get_shape_params_function.FunctionArgs.LabelMatrix.InputArg='CellsLabel';
start_tracks_function.InstanceName='StartTracks';
start_tracks_function.FunctionHandle=@startTracks;
start_tracks_function.FunctionArgs.CellsLabel.FunctionInstance='IfIsEmptyPreviousCellsLabel';
start_tracks_function.FunctionArgs.CellsLabel.InputArg='CellsLabel'; %only works for subfunctions
start_tracks_function.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
start_tracks_function.FunctionArgs.CurFrame.InputArg='CurFrame'; %only works for subfunctions
start_tracks_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;
start_tracks_function.FunctionArgs.ShapeParameters.FunctionInstance='GetShapeParameters';
start_tracks_function.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters';
get_cur_tracks_function.InstanceName='GetCurrentTracks';
get_cur_tracks_function.FunctionHandle=@getCurrentTracks;
get_cur_tracks_function.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
get_cur_tracks_function.FunctionArgs.Tracks.InputArg='Tracks';
get_cur_tracks_function.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
get_cur_tracks_function.FunctionArgs.CurFrame.InputArg='CurFrame';
get_cur_tracks_function.FunctionArgs.OffsetFrame.Value=-1;

get_cur_tracks_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;
get_cur_tracks_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCol;
get_cur_tracks_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;
get_cur_tracks_function.FunctionArgs.MaxMissingFrames.Value=TrackStruct.MaxFramesMissing;
get_prev_tracks_function=get_cur_tracks_function;
get_prev_tracks_function.InstanceName='GetPreviousTracks';
get_prev_tracks_function.FunctionArgs.OffsetFrame.Value=-2;
make_unassigned_cells_list_function.InstanceName='MakeUnassignedCellsList';
make_unassigned_cells_list_function.FunctionHandle=@makeUnassignedCellsList;
make_unassigned_cells_list_function.FunctionArgs.CellsCentroids.FunctionInstance='GetShapeParameters';
make_unassigned_cells_list_function.FunctionArgs.CellsCentroids.OutputArg='Centroids';
make_excluded_tracks_list_function.InstanceName='MakeExcludedTracksList';
make_excluded_tracks_list_function.FunctionHandle=@makeExcludedTracksList;
make_excluded_tracks_list_function.FunctionArgs.UnassignedCellsIDs.FunctionInstance='MakeUnassignedCellsList';
make_excluded_tracks_list_function.FunctionArgs.UnassignedCellsIDs.OutputArg='UnassignedCellsIDs';
get_mean_displacement_function.InstanceName='GetCellsMeanDisplacement';
get_mean_displacement_function.FunctionHandle=@getObjectsMeanDisplacement;
get_mean_displacement_function.FunctionArgs.ObjectCentroids.FunctionInstance='GetShapeParameters';
get_mean_displacement_function.FunctionArgs.ObjectCentroids.OutputArg='Centroids';
get_mean_displacement_function.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks';
get_mean_displacement_function.FunctionArgs.CurrentTracks.OutputArg='Tracks';
get_mean_displacement_function.FunctionArgs.Centroid1Col.Value=tracks_layout.Centroid1Col;
get_mean_displacement_function.FunctionArgs.Centroid2Col.Value=tracks_layout.Centroid2Col;
get_params_coeff_of_variation_function.InstanceName='GetParamsCoefficientOfVariation';
get_params_coeff_of_variation_function.FunctionHandle=@getParamsCoefficientOfVariation;
get_params_coeff_of_variation_function.FunctionArgs.Params.FunctionInstance='GetShapeParameters';
get_params_coeff_of_variation_function.FunctionArgs.Params.OutputArg='ShapeParameters';
get_params_coeff_of_variation_function.FunctionArgs.AreaCol.Value=tracks_layout.AreaCol;
get_params_coeff_of_variation_function.FunctionArgs.SolidityCol.Value=tracks_layout.SolCol;
get_max_track_id_function.InstanceName='GetMaxTrackID';
get_max_track_id_function.FunctionHandle=@getMaxTrackID;
get_max_track_id_function.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
get_max_track_id_function.FunctionArgs.Tracks.OutputArg='Tracks';
get_max_track_id_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;

assign_cells_to_tracks_loop.InstanceName='AssignCellsToTracksLoop';
assign_cells_to_tracks_loop.FunctionHandle=@whileLoop;
assign_cells_to_tracks_loop.TestFunction.InstanceName='IsNotEmptyUnassignedCells';
assign_cells_to_tracks_loop.TestFunction.FunctionHandle=@isNotEmptyFunction;
assign_cells_to_tracks_loop.TestFunction.FunctionArgs.TestVariable.FunctionInstance='AssignCellsToTracksLoop';
assign_cells_to_tracks_loop.TestFunction.FunctionArgs.TestVariable.InputArg='UnassignedCells';
assign_cells_to_tracks_loop.FunctionArgs.TestResult.FunctionInstance='IsNotEmptyUnassignedCells';
assign_cells_to_tracks_loop.FunctionArgs.TestResult.OutputArg='Boolean';
assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.FunctionInstance='MakeUnassignedCellsList';
assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.OutputArg='UnassignedCellsIDs';
assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.FunctionInstance2='AssignCellToTrackUsingAll';
assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.OutputArg2='UnassignedIDs';
assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.FunctionInstance='MakeExcludedTracksList';
assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.OutputArg='ExcludedTracks';
assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.FunctionInstance2='AssignCellToTrackUsingAll';
assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.OutputArg2='ExcludedTracks';
assign_cells_to_tracks_loop.FunctionArgs.CellsLabel.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.CellsLabel.InputArg='CellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.PreviousCellsLabel.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.PreviousCellsLabel.InputArg='PreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.ShapeParameters.FunctionInstance='GetShapeParameters';
assign_cells_to_tracks_loop.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters';
assign_cells_to_tracks_loop.FunctionArgs.CellsCentroids.FunctionInstance='GetShapeParameters';
assign_cells_to_tracks_loop.FunctionArgs.CellsCentroids.OutputArg='Centroids';
assign_cells_to_tracks_loop.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks';
assign_cells_to_tracks_loop.FunctionArgs.CurrentTracks.OutputArg='Tracks';
assign_cells_to_tracks_loop.FunctionArgs.SearchRadius.FunctionInstance='GetCellsMeanDisplacement';
assign_cells_to_tracks_loop.FunctionArgs.SearchRadius.OutputArg='SearchRadius';
assign_cells_to_tracks_loop.FunctionArgs.TrackAssignments.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.TrackAssignments.InputArg='TrackAssignments';
assign_cells_to_tracks_loop.FunctionArgs.TrackAssignments.FunctionInstance2='AssignCellToTrackUsingAll';
assign_cells_to_tracks_loop.FunctionArgs.TrackAssignments.OutputArg2='TrackAssignments';
assign_cells_to_tracks_loop.FunctionArgs.MaxTrackID.FunctionInstance='GetMaxTrackID';
assign_cells_to_tracks_loop.FunctionArgs.MaxTrackID.OutputArg='MaxTrackID';
assign_cells_to_tracks_loop.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.Tracks.InputArg='Tracks';
assign_cells_to_tracks_loop.FunctionArgs.MatchingGroups.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.MatchingGroups.InputArg='MatchingGroups';
assign_cells_to_tracks_loop.FunctionArgs.MatchingGroups.FunctionInstance2='AssignCellToTrackUsingAll';
assign_cells_to_tracks_loop.FunctionArgs.MatchingGroups.OutputArg2='MatchingGroups';
assign_cells_to_tracks_loop.FunctionArgs.ParamsCoeffOfVariation.FunctionInstance='GetParamsCoefficientOfVariation';
assign_cells_to_tracks_loop.FunctionArgs.ParamsCoeffOfVariation.OutputArg='CoefficientOfVariation';
assign_cells_to_tracks_loop.FunctionArgs.PreviousTracks.FunctionInstance='GetPreviousTracks';
assign_cells_to_tracks_loop.FunctionArgs.PreviousTracks.OutputArg='Tracks';
assign_cells_to_tracks_loop.KeepValues.TrackAssignments.FunctionInstance='AssignCellToTrackUsingAll';
assign_cells_to_tracks_loop.KeepValues.TrackAssignments.OutputArg='TrackAssignments';
assign_cells_to_tracks_loop.KeepValues.ShapeParameters.FunctionInstance='SetMatchingGroupIndex';
assign_cells_to_tracks_loop.KeepValues.ShapeParameters.OutputArg='ShapeParameters';
assign_cells_to_tracks_loop.KeepValues.MatchingGroups.FunctionInstance='AssignCellToTrackUsingAll';
assign_cells_to_tracks_loop.KeepValues.MatchingGroups.OutputArg='MatchingGroups';

get_current_unassigned_cell_function.InstanceName='GetCurrentUnassignedCell';
get_current_unassigned_cell_function.FunctionHandle=@getCurrentUnassignedCell;
get_current_unassigned_cell_function.FunctionArgs.UnassignedCells.FunctionInstance='AssignCellsToTracksLoop';
get_current_unassigned_cell_function.FunctionArgs.UnassignedCells.InputArg='UnassignedCells';
assign_cell_to_track_function.InstanceName='AssignCellToTrackUsingAll';
assign_cell_to_track_function.FunctionHandle=@assignCellToTrackUsingAll;
assign_cell_to_track_function.FunctionArgs.UnassignedCells.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.UnassignedCells.InputArg='UnassignedCells';
assign_cell_to_track_function.FunctionArgs.ExcludedTracks.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.ExcludedTracks.InputArg='ExcludedTracks';
assign_cell_to_track_function.FunctionArgs.CellsLabel.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.CellsLabel.InputArg='CellsLabel';
assign_cell_to_track_function.FunctionArgs.PreviousCellsLabel.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.PreviousCellsLabel.InputArg='PreviousCellsLabel';
assign_cell_to_track_function.FunctionArgs.ShapeParameters.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.ShapeParameters.InputArg='ShapeParameters';
assign_cell_to_track_function.FunctionArgs.CellsCentroids.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.CellsCentroids.InputArg='CellsCentroids';
assign_cell_to_track_function.FunctionArgs.CurrentTracks.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.CurrentTracks.InputArg='CurrentTracks';
assign_cell_to_track_function.FunctionArgs.SearchRadius.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.SearchRadius.InputArg='SearchRadius';
assign_cell_to_track_function.FunctionArgs.TrackAssignments.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.TrackAssignments.InputArg='TrackAssignments';
assign_cell_to_track_function.FunctionArgs.MaxTrackID.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.MaxTrackID.InputArg='MaxTrackID';
assign_cell_to_track_function.FunctionArgs.Tracks.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.Tracks.InputArg='Tracks';
assign_cell_to_track_function.FunctionArgs.MatchingGroups.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.MatchingGroups.InputArg='MatchingGroups';
assign_cell_to_track_function.FunctionArgs.ParamsCoeffOfVariation.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.ParamsCoeffOfVariation.InputArg='ParamsCoeffOfVariation';
assign_cell_to_track_function.FunctionArgs.PreviousTracks.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.PreviousTracks.InputArg='PreviousTracks';
assign_cell_to_track_function.FunctionArgs.TrackStruct.Value=TrackStruct;
set_group_index_function.InstanceName='SetMatchingGroupIndex';
set_group_index_function.FunctionHandle=@setGroupIndex;
set_group_index_function.FunctionArgs.ShapeParameters.FunctionInstance='AssignCellsToTracksLoop';
set_group_index_function.FunctionArgs.ShapeParameters.InputArg='ShapeParameters';
set_group_index_function.FunctionArgs.CellID.FunctionInstance='GetCurrentUnassignedCell';
set_group_index_function.FunctionArgs.CellID.OutputArg='CellID';
set_group_index_function.FunctionArgs.GroupIndex.FunctionInstance='AssignCellToTrackUsingAll';
set_group_index_function.FunctionArgs.GroupIndex.OutputArg='GroupIndex';
set_group_index_function.FunctionArgs.AreaCol.Value=tracks_layout.AreaCol;
set_group_index_function.FunctionArgs.GroupIDCol.Value=tracks_layout.MatchGroupIDCol;

assign_cells_to_tracks_loop.LoopFunctions=[{get_current_unassigned_cell_function}; {assign_cell_to_track_function};...
    {set_group_index_function}];

continue_tracks_function.InstanceName='ContinueTracks';
continue_tracks_function.FunctionHandle=@continueTracks;
continue_tracks_function.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
continue_tracks_function.FunctionArgs.Tracks.InputArg='Tracks';
continue_tracks_function.FunctionArgs.TrackAssignments.FunctionInstance='AssignCellsToTracksLoop';
continue_tracks_function.FunctionArgs.TrackAssignments.OutputArg='TrackAssignments';
continue_tracks_function.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
continue_tracks_function.FunctionArgs.CurFrame.InputArg='CurFrame';
continue_tracks_function.FunctionArgs.CellsCentroids.FunctionInstance='GetShapeParameters';
continue_tracks_function.FunctionArgs.CellsCentroids.OutputArg='Centroids';
continue_tracks_function.FunctionArgs.ShapeParameters.FunctionInstance='GetShapeParameters';
continue_tracks_function.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters';
continue_tracks_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;

if_is_empty_cells_label_function.IfFunctions=[{get_shape_params_function};{start_tracks_function}];

if_is_empty_cells_label_function.ElseFunctions=[{get_cur_tracks_function};{get_prev_tracks_function};{get_shape_params_function};...
    {make_unassigned_cells_list_function};{make_excluded_tracks_list_function};{get_mean_displacement_function};...
    {get_params_coeff_of_variation_function};{get_max_track_id_function};{assign_cells_to_tracks_loop};{continue_tracks_function}];

save_cells_label_function.InstanceName='SaveCellsLabel';
save_cells_label_function.FunctionHandle=@saveCellsLabel;
save_cells_label_function.FunctionArgs.CellsLabel.FunctionInstance='ResizeCytoLabel';
save_cells_label_function.FunctionArgs.CellsLabel.OutputArg='Image';
save_cells_label_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
save_cells_label_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
save_cells_label_function.FunctionArgs.FileRoot.Value=TrackStruct.SegFileRoot;
save_cells_label_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberFormat;
display_tracks_function.InstanceName='DisplayTracks';
display_tracks_function.FunctionHandle=@displayTracksData;
display_tracks_function.FunctionArgs.Image.FunctionInstance='ReadImagesInSegmentationLoop';
display_tracks_function.FunctionArgs.Image.OutputArg='Image';
display_tracks_function.FunctionArgs.CellsLabel.FunctionInstance='ResizeCytoLabel';
display_tracks_function.FunctionArgs.CellsLabel.OutputArg='Image';
display_tracks_function.FunctionArgs.CurrentTracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
display_tracks_function.FunctionArgs.CurrentTracks.OutputArg='NewTracks';
display_tracks_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
display_tracks_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
display_tracks_function.FunctionArgs.TracksLayout.Value=tracks_layout;
display_tracks_function.FunctionArgs.FileRoot.Value=[track_dir ds TrackStruct.ImageFileName];
display_tracks_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberFormat;

image_read_loop.LoopFunctions=[{display_curtrackframe_function};{make_file_name_function};{read_image_function};...
    {normalize_image_to_16bit_function};{resize_image_function};{cyto_local_avg_filter_function};{cyto_global_int_filter_function};...
    {combine_cyto_images_function};{fill_holes_cyto_images_function};{clear_small_cells_function};{nucl_local_avg_filter_function};...
    {nucl_global_int_filter_function};{combine_nucl_images_function};{fill_holes_nucl_images_function};{clear_small_nuclei_function};...
    {combine_nucl_plus_cyto_function};{reconstruct_cyto_function};{label_nuclei_function};{label_cyto_function};{get_convex_objects_function};...
    {distance_watershed_function};{polygonal_assisted_watershed_function};{segment_objects_using_markers_function};...
    {clear_small_components_function};{resize_cyto_label_function};{if_is_empty_cells_label_function};{save_cells_label_function};...
    {display_tracks_function}];

save_tracks_function.InstanceName='SaveTracks';
save_tracks_function.FunctionHandle=@saveTracks;
save_tracks_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
save_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
save_tracks_function.FunctionArgs.TracksFileName.Value=TrackStruct.TracksFile;

save_matching_groups_function.InstanceName='SaveMatchingGroups';
save_matching_groups_function.FunctionHandle=@saveMatchingGroups;
save_matching_groups_function.FunctionArgs.MatchingGroups.FunctionInstance='SegmentationLoop';
save_matching_groups_function.FunctionArgs.MatchingGroups.OutputArg='MatchingGroups';
save_matching_groups_function.FunctionArgs.MatchingGroupsFileName.Value=TrackStruct.RankFile;

validate_tracks_function.InstanceName='ValidateTracks';
validate_tracks_function.FunctionHandle=@validate_tracks;
validate_tracks_function.FunctionArgs.TrackStruct.Value=TrackStruct;

functions_list=[{display_trackstruct_function};{image_read_loop};{save_tracks_function};{save_matching_groups_function};...
    {validate_tracks_function}];

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end function
end