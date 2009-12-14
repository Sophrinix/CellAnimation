function []=darren_fl_test_track(well_folder)
TrackStruct=[];
TrackStruct.ImgExt='.tif';
ds='\'  %directory symbol
TrackStruct.DS=ds;
root_folder='I:\darren';
TrackStruct.ImageFileName='DsRed - Confocal - n';
%low hepsin expressing - not really wildtype
TrackStruct.ImageFileBase=[well_folder ds TrackStruct.ImageFileName];
%hepsin overexpressing
% TrackStruct.ImageFileBase=[well_folder ds 'llh_hep_lm7_t'];

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
prol_dir=[TrackStruct.OutputFolder ds 'proliferation'];
TrackStruct.ProlDir=prol_dir;
mkdir(prol_dir);
TrackStruct.ProlFileRoot=[prol_dir ds 'prol'];
xls_folder=[root_folder ds 'spreadsheets'];
mkdir(xls_folder);
TrackStruct.ProlXlsFile=[xls_folder ds well_name '.csv'];
TrackStruct.ShapesXlsFile=[xls_folder ds well_name '_shapes.csv'];
TrackStruct.StartFrame=15;
TrackStruct.FrameCount=30;
TrackStruct.TimeFrame=15; %minutes
TrackStruct.FrameStep=1; %read every x frames
TrackStruct.NumberFormat='%06d';
TrackStruct.MaxFramesMissing=2; %how many frames a cell can disappear before we end its track
%toolbox struct
param=[];
param.mem=3;   % how many frames can a cell disappear for and still count towards a trajectory.
param.dim=2;   % don't change this value
param.good=10;   % minimum size (frames) of cell centroids to count as a valid trajectory.
param.quiet=0;   % make this one to suppress output, zero to show output.
TrackStruct.ToolboxParams=param;

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
TrackStruct.TracksLayout=tracks_layout;

%ancestry grid layout
ancestry_layout.TrackIDCol=1;
ancestry_layout.ParentIDCol=2;
ancestry_layout.GenerationCol=3;
ancestry_layout.StartTimeCol=4;
ancestry_layout.StopTimeCol=5;
TrackStruct.AncestryLayout=ancestry_layout;

TrackStruct.SearchRadius=40;
% TrackStruct.SearchRadius=20;
TrackStruct.Channel='';
TrackStruct.MinCytoArea=40;
TrackStruct.MinNuclArea=40;
TrackStruct.bContourLink=false;
TrackStruct.LinkDist=1;
TrackStruct.ObjectReduce=0.3;
TrackStruct.ClusterDist=5;
TrackStruct.bCytoLocalAvg=true;
TrackStruct.CytoBrightThreshold=1.15;
TrackStruct.bNuclLocalAvg=true;
TrackStruct.NuclBrightThreshold=1.15;
TrackStruct.bCytoGrad=false;
TrackStruct.CytoGradThreshold=2800;
TrackStruct.bNuclGrad=false;
TrackStruct.NuclGradThreshold=2800;
TrackStruct.bCytoInt=false;
TrackStruct.bSmoothContours=false;
TrackStruct.bNuclInt=false;
TrackStruct.bMaxEcc=false;
TrackStruct.MaxCellEcc=0.99;
TrackStruct.bClearBorder=true;
TrackStruct.IntensityThreshold=1;
TrackStruct.L1=1.2;
TrackStruct.L2=0.6;
TrackStruct.L3=2;
TrackStruct.Alpha1=5*pi/6;
TrackStruct.Alpha2=pi/2;
TrackStruct.MinPolArea=80;
TrackStruct.ApproxDist=2;
TrackStruct.ClearBorderDist=2;
TrackStruct.WatershedMed=1;
TrackStruct.MaxMergeDist=35;
TrackStruct.MaxSplitDist=40;

disp(TrackStruct)

cells_track(TrackStruct);
validate_tracks(TrackStruct);
%end function
end