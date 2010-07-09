function []=pipelineFlCytoLNCapTrackWG(well_folder)
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
TrackStruct.StartFrame=1;
TrackStruct.FrameCount=30;
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
TrackStruct.ClusterDist=7.5;
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
image_read_loop.KeepValues.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.KeepValues.Tracks.OutputArg='Tracks';
image_read_loop.KeepValues.MatchingGroups.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.KeepValues.MatchingGroups.OutputArg='MatchingGroups';

display_curtrackframe_function.InstanceName='DisplayCurFrame';
display_curtrackframe_function.FunctionHandle=@displayVariable;
display_curtrackframe_function.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
display_curtrackframe_function.FunctionArgs.Variable.OutputArg='LoopCounter';
display_curtrackframe_function.FunctionArgs.VariableName.Value='Current Tracking Frame';


make_mat_name_function2.InstanceName='MakeMatNamesInOverlayLoop2';
make_mat_name_function2.FunctionHandle=@makeImgFileName;
make_mat_name_function2.FunctionArgs.FileBase.Value=TrackStruct.SegFileRoot;
make_mat_name_function2.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
make_mat_name_function2.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_mat_name_function2.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_mat_name_function2.FunctionArgs.FileExt.Value='.mat';

load_cells_label_function2.InstanceName='LoadCellsLabel2';
load_cells_label_function2.FunctionHandle=@loadMatFile;
load_cells_label_function2.FunctionArgs.MatFileName.FunctionInstance='MakeMatNamesInOverlayLoop2';
load_cells_label_function2.FunctionArgs.MatFileName.OutputArg='FileName';

%tracking
if_is_empty_cells_label_function.InstanceName='IfIsEmptyPreviousCellsLabel';
if_is_empty_cells_label_function.FunctionHandle=@if_statement;
if_is_empty_cells_label_function.FunctionArgs.TestResult.FunctionInstance='IsEmptyPreviousCellsLabel';
if_is_empty_cells_label_function.FunctionArgs.TestResult.OutputArg='Boolean';
if_is_empty_cells_label_function.FunctionArgs.CellsLabel.FunctionInstance='LoadCellsLabel2';
if_is_empty_cells_label_function.FunctionArgs.CellsLabel.OutputArg='cells_lbl';
if_is_empty_cells_label_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
if_is_empty_cells_label_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
if_is_empty_cells_label_function.FunctionArgs.PreviousCellsLabel.FunctionInstance='StorePreviousCellLabel';
if_is_empty_cells_label_function.FunctionArgs.PreviousCellsLabel.OutputArg='PreviousCellsLabel';
if_is_empty_cells_label_function.FunctionArgs.PreviousCellsLabel.Value=[];
if_is_empty_cells_label_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
if_is_empty_cells_label_function.FunctionArgs.Tracks.OutputArg='Tracks';
if_is_empty_cells_label_function.FunctionArgs.Tracks.Value=[];
if_is_empty_cells_label_function.FunctionArgs.MatchingGroups.FunctionInstance='SegmentationLoop';
if_is_empty_cells_label_function.FunctionArgs.MatchingGroups.InputArg='MatchingGroups';
if_is_empty_cells_label_function.FunctionArgs.MatchingGroupsStats.FunctionInstance='GetMatchingGroupMeans';
if_is_empty_cells_label_function.FunctionArgs.MatchingGroupsStats.OutputArg='MatchingGroupStats';
if_is_empty_cells_label_function.FunctionArgs.MatchingGroupsStats.Value=[];
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

store_previous_cell_label_function.InstanceName='StorePreviousCellLabel';
store_previous_cell_label_function.FunctionHandle=@storeValues;
store_previous_cell_label_function.FunctionArgs.PreviousCellsLabel.FunctionInstance='LoadCellsLabel2';
store_previous_cell_label_function.FunctionArgs.PreviousCellsLabel.OutputArg='cells_lbl';


get_shape_params_function.InstanceName='GetShapeParameters';
get_shape_params_function.FunctionHandle=@getShapeParamsWithDisconnects;
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
get_cur_tracks_function.FunctionArgs.FrameStep.Value=TrackStruct.FrameStep;

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
assign_cells_to_tracks_loop.FunctionArgs.ShapeParameters.FunctionInstance2='SetMatchingGroupIndex';
assign_cells_to_tracks_loop.FunctionArgs.ShapeParameters.OutputArg2='ShapeParameters';
assign_cells_to_tracks_loop.FunctionArgs.CellsCentroids.FunctionInstance='GetShapeParameters';
assign_cells_to_tracks_loop.FunctionArgs.CellsCentroids.OutputArg='Centroids';
assign_cells_to_tracks_loop.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks';
assign_cells_to_tracks_loop.FunctionArgs.CurrentTracks.OutputArg='Tracks';
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
assign_cells_to_tracks_loop.FunctionArgs.MatchingGroupsStats.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assign_cells_to_tracks_loop.FunctionArgs.MatchingGroupsStats.InputArg='MatchingGroupsStats';
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
assign_cell_to_track_function.FunctionArgs.CheckCellPath.Value=true;
%how far from the nearest future cell we should look for possible matches
%to our present cell. ie 1.5 means we should look one and a half times the
%distance between the current cell and the nearest future cell
assign_cell_to_track_function.FunctionArgs.MaxSearchRadius.Value=Inf;
assign_cell_to_track_function.FunctionArgs.MinSearchRadius.Value=0;
assign_cell_to_track_function.FunctionArgs.SearchRadiusPct.Value=1.5;
assign_cell_to_track_function.FunctionArgs.TrackAssignments.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.TrackAssignments.InputArg='TrackAssignments';
assign_cell_to_track_function.FunctionArgs.MaxTrackID.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.MaxTrackID.InputArg='MaxTrackID';
assign_cell_to_track_function.FunctionArgs.Tracks.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.Tracks.InputArg='Tracks';
assign_cell_to_track_function.FunctionArgs.MatchingGroups.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.MatchingGroups.InputArg='MatchingGroups';
assign_cell_to_track_function.FunctionArgs.MatchingGroupsStats.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.MatchingGroupsStats.InputArg='MatchingGroupsStats';
assign_cell_to_track_function.FunctionArgs.ParamsCoeffOfVariation.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.ParamsCoeffOfVariation.InputArg='ParamsCoeffOfVariation';
assign_cell_to_track_function.FunctionArgs.PreviousTracks.FunctionInstance='AssignCellsToTracksLoop';
assign_cell_to_track_function.FunctionArgs.PreviousTracks.InputArg='PreviousTracks';
assign_cell_to_track_function.FunctionArgs.TracksLayout.Value=tracks_layout;
assign_cell_to_track_function.FunctionArgs.FrontParams.Value=TrackStruct.FrontParams;
assign_cell_to_track_function.FunctionArgs.RelevantParametersIndex.Value=...
    [true true true false true false true true false];
assign_cell_to_track_function.FunctionArgs.NrParamsForSureMatch.Value=TrackStruct.NrParamsForSureMatch;
assign_cell_to_track_function.FunctionArgs.DefaultParamWeights.Value=TrackStruct.DefaultParamWeights;
assign_cell_to_track_function.FunctionArgs.UnknownParamWeights.Value=TrackStruct.UnknownParamWeights;
assign_cell_to_track_function.FunctionArgs.DistanceRankingOrder.Value=TrackStruct.DistanceRankingOrder;
assign_cell_to_track_function.FunctionArgs.DirectionRankingOrder.Value=TrackStruct.DirectionRankingOrder;
assign_cell_to_track_function.FunctionArgs.UnknownRankingOrder.Value=TrackStruct.UnknownRankingOrder;
assign_cell_to_track_function.FunctionArgs.MinSecondDistance.Value=TrackStruct.MinSecondDistance;
assign_cell_to_track_function.FunctionArgs.MaxDistRatio.Value=TrackStruct.MaxDistRatio;
assign_cell_to_track_function.FunctionArgs.MaxAngleDiff.Value=TrackStruct.MaxAngleDiff;
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
continue_tracks_function.FunctionArgs.ShapeParameters.FunctionInstance='AssignCellsToTracksLoop';
continue_tracks_function.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters';
continue_tracks_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;

get_matching_groups_means_function.InstanceName='GetMatchingGroupMeans';
get_matching_groups_means_function.FunctionHandle=@getMatchingGroupMeans;
get_matching_groups_means_function.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
get_matching_groups_means_function.FunctionArgs.Tracks.InputArg='Tracks';
get_matching_groups_means_function.FunctionArgs.TracksLayout.Value=tracks_layout;

if_is_empty_cells_label_function.IfFunctions=[{get_shape_params_function};{start_tracks_function}];

if_is_empty_cells_label_function.ElseFunctions=[{get_cur_tracks_function};{get_prev_tracks_function};{get_shape_params_function};...
    {make_unassigned_cells_list_function};{make_excluded_tracks_list_function};{get_mean_displacement_function};...
    {get_params_coeff_of_variation_function};{get_max_track_id_function};{assign_cells_to_tracks_loop};{continue_tracks_function}...
    ;{get_matching_groups_means_function}];


image_read_loop.LoopFunctions=[{display_curtrackframe_function};{make_mat_name_function2};...
    {load_cells_label_function2};{if_is_empty_cells_label_function};{store_previous_cell_label_function}];

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

get_track_ids_function.InstanceName='GetTrackIDs';
get_track_ids_function.FunctionHandle=@getTrackIDs;
get_track_ids_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
get_track_ids_function.FunctionArgs.Tracks.OutputArg='Tracks';
get_track_ids_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;

make_ancestry_for_first_frame_cells_function.InstanceName='MakeAncestryForFirstFrameCells';
make_ancestry_for_first_frame_cells_function.FunctionHandle=@makeAncestryForFirstFrameCells;
make_ancestry_for_first_frame_cells_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
make_ancestry_for_first_frame_cells_function.FunctionArgs.Tracks.OutputArg='Tracks';
make_ancestry_for_first_frame_cells_function.FunctionArgs.TrackIDs.FunctionInstance='GetTrackIDs';
make_ancestry_for_first_frame_cells_function.FunctionArgs.TrackIDs.OutputArg='TrackIDs';
make_ancestry_for_first_frame_cells_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCol;
make_ancestry_for_first_frame_cells_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;

detect_mitotic_events_function.InstanceName='DetectMitoticEvents';
detect_mitotic_events_function.FunctionHandle=@detectMitoticEvents;
detect_mitotic_events_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
detect_mitotic_events_function.FunctionArgs.Tracks.OutputArg='Tracks';
detect_mitotic_events_function.FunctionArgs.UntestedIDs.FunctionInstance='MakeAncestryForFirstFrameCells';
detect_mitotic_events_function.FunctionArgs.UntestedIDs.OutputArg='UntestedIDs';
detect_mitotic_events_function.FunctionArgs.TracksLayout.Value=tracks_layout;
detect_mitotic_events_function.FunctionArgs.MaxSplitArea.Value=TrackStruct.MaxSplitArea;
detect_mitotic_events_function.FunctionArgs.MinSplitEccentricity.Value=TrackStruct.MinSplitEcc;
detect_mitotic_events_function.FunctionArgs.MaxSplitEccentricity.Value=TrackStruct.MaxSplitEcc;
detect_mitotic_events_function.FunctionArgs.MaxSplitDistance.Value=TrackStruct.MaxSplitDist;
detect_mitotic_events_function.FunctionArgs.MinTimeForSplit.Value=TrackStruct.MinTimeForSplit;

make_ancestry_for_cells_entering_frames_function.InstanceName='MakeAncestryForCellsEnteringFrames';
make_ancestry_for_cells_entering_frames_function.FunctionHandle=@makeAncestryForCellsEnteringFrames;
make_ancestry_for_cells_entering_frames_function.FunctionArgs.SplitCells.FunctionInstance='DetectMitoticEvents';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.SplitCells.OutputArg='SplitCells';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.TrackIDs.FunctionInstance='GetTrackIDs';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.TrackIDs.OutputArg='TrackIDs';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.FirstFrameIDs.FunctionInstance='MakeAncestryForFirstFrameCells';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.FirstFrameIDs.OutputArg='FirstFrameIDs';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.CellsAncestry.FunctionInstance='MakeAncestryForFirstFrameCells';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.Tracks.OutputArg='Tracks';
make_ancestry_for_cells_entering_frames_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCol;
make_ancestry_for_cells_entering_frames_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;

split_tracks_function.InstanceName='SplitTracks';
split_tracks_function.FunctionHandle=@splitTracks;
split_tracks_function.FunctionArgs.SplitCells.FunctionInstance='DetectMitoticEvents';
split_tracks_function.FunctionArgs.SplitCells.OutputArg='SplitCells';
split_tracks_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
split_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
split_tracks_function.FunctionArgs.CellsAncestry.FunctionInstance='MakeAncestryForCellsEnteringFrames';
split_tracks_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
split_tracks_function.FunctionArgs.TracksLayout.Value=tracks_layout;
split_tracks_function.FunctionArgs.AncestryLayout.Value=ancestry_layout;
split_tracks_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;

remove_short_tracks_function.InstanceName='RemoveShortTracks';
remove_short_tracks_function.FunctionHandle=@removeShortTracks;
remove_short_tracks_function.FunctionArgs.Tracks.FunctionInstance='SplitTracks';
remove_short_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
remove_short_tracks_function.FunctionArgs.CellsAncestry.FunctionInstance='SplitTracks';
remove_short_tracks_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
remove_short_tracks_function.FunctionArgs.TracksLayout.Value=tracks_layout;
remove_short_tracks_function.FunctionArgs.AncestryLayout.Value=ancestry_layout;
remove_short_tracks_function.FunctionArgs.MinLifespan.Value=30; %minutes

save_updated_tracks_function.InstanceName='SaveUpdatedTracks';
save_updated_tracks_function.FunctionHandle=@saveTracks;
save_updated_tracks_function.FunctionArgs.Tracks.FunctionInstance='RemoveShortTracks';
save_updated_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
save_updated_tracks_function.FunctionArgs.TracksFileName.Value=[TrackStruct.ProlDir ds 'tracks.mat'];

save_ancestry_function.InstanceName='SaveAncestry';
save_ancestry_function.FunctionHandle=@saveAncestry;
save_ancestry_function.FunctionArgs.CellsAncestry.FunctionInstance='RemoveShortTracks';
save_ancestry_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
save_ancestry_function.FunctionArgs.AncestryFileName.Value=[TrackStruct.ProlDir ds 'ancestry.mat'];

image_overlay_loop.InstanceName='ImageOverlayLoop';
image_overlay_loop.FunctionHandle=@forLoop;
image_overlay_loop.FunctionArgs.StartLoop.Value=TrackStruct.StartFrame;
image_overlay_loop.FunctionArgs.EndLoop.Value=(TrackStruct.StartFrame+TrackStruct.FrameCount-1)*TrackStruct.FrameStep;
image_overlay_loop.FunctionArgs.IncrementLoop.Value=TrackStruct.FrameStep;
image_overlay_loop.FunctionArgs.Tracks.FunctionInstance='RemoveShortTracks';
image_overlay_loop.FunctionArgs.Tracks.OutputArg='Tracks';
image_overlay_loop.FunctionArgs.CellsAncestry.FunctionInstance='RemoveShortTracks';
image_overlay_loop.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';

make_file_name2_function.InstanceName='MakeImageNamesInOverlayLoop';
make_file_name2_function.FunctionHandle=@makeImgFileName;
make_file_name2_function.FunctionArgs.FileBase.Value=TrackStruct.ImageFileBase;
make_file_name2_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
make_file_name2_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_file_name2_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_file_name2_function.FunctionArgs.FileExt.Value=TrackStruct.ImgExt;

read_image2_function.InstanceName='ReadImagesInOverlayLoop';
read_image2_function.FunctionHandle=@readImage;
read_image2_function.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInOverlayLoop';
read_image2_function.FunctionArgs.ImageName.OutputArg='FileName';
read_image2_function.FunctionArgs.ImageChannel.Value='';

get_cur_tracks2_function.InstanceName='GetCurrentTracks2';
get_cur_tracks2_function.FunctionHandle=@getCurrentTracks;
get_cur_tracks2_function.FunctionArgs.Tracks.FunctionInstance='ImageOverlayLoop';
get_cur_tracks2_function.FunctionArgs.Tracks.InputArg='Tracks';
get_cur_tracks2_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
get_cur_tracks2_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
get_cur_tracks2_function.FunctionArgs.OffsetFrame.Value=0;
get_cur_tracks2_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;
get_cur_tracks2_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCol;
get_cur_tracks2_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;
get_cur_tracks2_function.FunctionArgs.MaxMissingFrames.Value=0;
get_cur_tracks2_function.FunctionArgs.FrameStep.Value=TrackStruct.FrameStep;

make_mat_name_function.InstanceName='MakeMatNamesInOverlayLoop';
make_mat_name_function.FunctionHandle=@makeImgFileName;
make_mat_name_function.FunctionArgs.FileBase.Value=TrackStruct.SegFileRoot;
make_mat_name_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
make_mat_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_mat_name_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_mat_name_function.FunctionArgs.FileExt.Value='.mat';

load_cells_label_function.InstanceName='LoadCellsLabel';
load_cells_label_function.FunctionHandle=@loadMatFile;
load_cells_label_function.FunctionArgs.MatFileName.FunctionInstance='MakeMatNamesInOverlayLoop';
load_cells_label_function.FunctionArgs.MatFileName.OutputArg='FileName';

load_colormap_function.InstanceName='LoadColormap';
load_colormap_function.FunctionHandle=@loadMatFile;
load_colormap_function.FunctionArgs.MatFileName.Value='colormap_lines';

display_overlaying_frame_function.InstanceName='DisplayOverlayingFrame';
display_overlaying_frame_function.FunctionHandle=@displayVariable;
display_overlaying_frame_function.FunctionArgs.Variable.FunctionInstance='ImageOverlayLoop';
display_overlaying_frame_function.FunctionArgs.Variable.OutputArg='LoopCounter';
display_overlaying_frame_function.FunctionArgs.VariableName.Value='Overlaying Frame';

display_ancestry_function.InstanceName='DisplayAncestry';
display_ancestry_function.FunctionHandle=@displayAncestryData;
display_ancestry_function.FunctionArgs.Image.FunctionInstance='ReadImagesInOverlayLoop';
display_ancestry_function.FunctionArgs.Image.OutputArg='Image';
display_ancestry_function.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks2';
display_ancestry_function.FunctionArgs.CurrentTracks.OutputArg='Tracks';
display_ancestry_function.FunctionArgs.CellsLabel.FunctionInstance='LoadCellsLabel';
display_ancestry_function.FunctionArgs.CellsLabel.OutputArg='cells_lbl';
display_ancestry_function.FunctionArgs.CellsAncestry.FunctionInstance='ImageOverlayLoop';
display_ancestry_function.FunctionArgs.CellsAncestry.InputArg='CellsAncestry';
display_ancestry_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
display_ancestry_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
display_ancestry_function.FunctionArgs.ColorMap.FunctionInstance='LoadColormap';
display_ancestry_function.FunctionArgs.ColorMap.OutputArg='cmap';
display_ancestry_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberFormat;
display_ancestry_function.FunctionArgs.TracksLayout.Value=tracks_layout;
display_ancestry_function.FunctionArgs.ProlDir.Value=TrackStruct.ProlDir;
display_ancestry_function.FunctionArgs.ImageFileName.Value=TrackStruct.ImageFileName;
display_ancestry_function.FunctionArgs.DS.Value=ds;
display_ancestry_function.FunctionArgs.AncestryLayout.Value=ancestry_layout;


image_overlay_loop.LoopFunctions=[{make_file_name2_function};{read_image2_function};{get_cur_tracks2_function};{make_mat_name_function};...
    {load_cells_label_function};{load_colormap_function};{display_overlaying_frame_function};{display_ancestry_function}];

save_ancestry_spreadsheets.InstanceName='SaveAncestrySpreadsheets';
save_ancestry_spreadsheets.FunctionHandle=@saveAncestrySpreadsheets;
save_ancestry_spreadsheets.FunctionArgs.Tracks.FunctionInstance='RemoveShortTracks';
save_ancestry_spreadsheets.FunctionArgs.Tracks.OutputArg='Tracks';
save_ancestry_spreadsheets.FunctionArgs.CellsAncestry.FunctionInstance='RemoveShortTracks';
save_ancestry_spreadsheets.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
save_ancestry_spreadsheets.FunctionArgs.TracksLayout.Value=tracks_layout;
save_ancestry_spreadsheets.FunctionArgs.ShapesXlsFile.Value=TrackStruct.ShapesXlsFile;
save_ancestry_spreadsheets.FunctionArgs.ProlXlsFile.Value=TrackStruct.ProlXlsFile;


functions_list=[{display_trackstruct_function};{image_read_loop};{save_tracks_function};{save_matching_groups_function};...
    {get_track_ids_function};...
    {make_ancestry_for_first_frame_cells_function};{detect_mitotic_events_function};{make_ancestry_for_cells_entering_frames_function};...
    {split_tracks_function};{remove_short_tracks_function};{save_updated_tracks_function};{save_ancestry_function};{image_overlay_loop};...
    {save_ancestry_spreadsheets}];

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end function
end