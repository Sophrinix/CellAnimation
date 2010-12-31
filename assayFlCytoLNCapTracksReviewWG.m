function []=assayFlCytoLNCapTracksReviewWG(well_folder)
%assay to review tracking of LNCap cells stained with Cell Tracker

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
TrackStruct.StartFrame=31;
TrackStruct.FrameCount=29;
TrackStruct.TimeFrame=8; %minutes
TrackStruct.FrameStep=1; %read every x frames
TrackStruct.NumberFormat='%06d';
TrackStruct.MaxFramesMissing=6; %how many frames a cell can disappear before we end its track
TrackStruct.FrontParams=[];
global functions_list;


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


load_tracks_function.InstanceName='LoadTracks';
load_tracks_function.FunctionHandle=@loadMatFile;
load_tracks_function.FunctionArgs.MatFileName.Value=[TrackStruct.ProlDir ds 'tracks.mat'];

load_ancestry_function.InstanceName='LoadAncestry';
load_ancestry_function.FunctionHandle=@loadMatFile;
load_ancestry_function.FunctionArgs.MatFileName.Value=[TrackStruct.ProlDir ds 'ancestry.mat'];

load_colormap_function.InstanceName='LoadColormap';
load_colormap_function.FunctionHandle=@loadMatFile;
load_colormap_function.FunctionArgs.MatFileName.Value='colormap_lines';

manual_tracks_review_function.InstanceName='ManualTracksReview';
manual_tracks_review_function.FunctionHandle=@manualTrackingReview;
manual_tracks_review_function.FunctionArgs.Tracks.FunctionInstance='LoadTracks';
manual_tracks_review_function.FunctionArgs.Tracks.OutputArg='tracks';
manual_tracks_review_function.FunctionArgs.CellsAncestry.FunctionInstance='LoadAncestry';
manual_tracks_review_function.FunctionArgs.CellsAncestry.OutputArg='cells_ancestry';
manual_tracks_review_function.FunctionArgs.ColorMap.FunctionInstance='LoadColormap';
manual_tracks_review_function.FunctionArgs.ColorMap.OutputArg='cmap';
manual_tracks_review_function.FunctionArgs.ImageFileBase.Value=TrackStruct.ImageFileBase;
manual_tracks_review_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberFormat;
manual_tracks_review_function.FunctionArgs.ImgExt.Value=TrackStruct.ImgExt;
manual_tracks_review_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;
manual_tracks_review_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCol;
manual_tracks_review_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;
manual_tracks_review_function.FunctionArgs.MaxMissingFrames.Value=TrackStruct.MaxFramesMissing;
manual_tracks_review_function.FunctionArgs.FrameStep.Value=TrackStruct.FrameStep;
manual_tracks_review_function.FunctionArgs.TracksLayout.Value=tracks_layout;
manual_tracks_review_function.FunctionArgs.SegFileRoot.Value=TrackStruct.SegFileRoot;
manual_tracks_review_function.FunctionArgs.AncestryLayout.Value=ancestry_layout;
manual_tracks_review_function.FunctionArgs.FrameCount.Value=TrackStruct.FrameCount;
manual_tracks_review_function.FunctionArgs.StartFrame.Value=TrackStruct.StartFrame;


save_updated_tracks_function.InstanceName='SaveUpdatedTracks';
save_updated_tracks_function.FunctionHandle=@saveTracks;
save_updated_tracks_function.FunctionArgs.Tracks.FunctionInstance='ManualTracksReview';
save_updated_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
save_updated_tracks_function.FunctionArgs.TracksFileName.Value=[TrackStruct.ProlDir ds 'tracks.mat'];

save_ancestry_function.InstanceName='SaveAncestry';
save_ancestry_function.FunctionHandle=@saveAncestry;
save_ancestry_function.FunctionArgs.CellsAncestry.FunctionInstance='ManualTracksReview';
save_ancestry_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
save_ancestry_function.FunctionArgs.AncestryFileName.Value=[TrackStruct.ProlDir ds 'ancestry.mat'];


save_ancestry_spreadsheets.InstanceName='SaveAncestrySpreadsheets';
save_ancestry_spreadsheets.FunctionHandle=@saveAncestrySpreadsheets;
save_ancestry_spreadsheets.FunctionArgs.Tracks.FunctionInstance='ManualTracksReview';
save_ancestry_spreadsheets.FunctionArgs.Tracks.OutputArg='Tracks';
save_ancestry_spreadsheets.FunctionArgs.CellsAncestry.FunctionInstance='ManualTracksReview';
save_ancestry_spreadsheets.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
save_ancestry_spreadsheets.FunctionArgs.TracksLayout.Value=tracks_layout;
save_ancestry_spreadsheets.FunctionArgs.ShapesXlsFile.Value=TrackStruct.ShapesXlsFile;
save_ancestry_spreadsheets.FunctionArgs.ProlXlsFile.Value=TrackStruct.ProlXlsFile;


functions_list=[{load_tracks_function};{load_ancestry_function};{load_colormap_function};{manual_tracks_review_function};...
    {save_updated_tracks_function};{save_ancestry_function};{save_ancestry_spreadsheets}];

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end function
end