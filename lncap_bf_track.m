function []=lncap_bf_track(well_folder)
TrackStruct=[];
TrackStruct.ImgExt='.tif';
ds='\'  %directory symbol
TrackStruct.DS=ds;
root_folder='I:\manisha';
%low hepsin expressing - not really wildtype
TrackStruct.ImageFileBase=[well_folder ds 'llh_wt_lm5_t'];
%hepsin overexpressing
% TrackStruct.ImageFileBase=[well_folder ds 'llh_hep_lm7_t'];

name_idx=find(well_folder==ds,2,'last');
%generate a unique well name
well_name=well_folder((name_idx(1)+1):end);
well_name(name_idx(2)-name_idx(1))=[];
well_name(well_name==' ')=[];
TrackStruct.OutputFolder=[root_folder ds 'output' ds well_name];
track_dir=[TrackStruct.OutputFolder ds 'track'];
mkdir(track_dir);
TrackStruct.SegFileRoot=[track_dir ds 'grayscale'];
TrackStruct.TracksFile=[track_dir ds 'tracks.mat'];
prol_dir=[TrackStruct.OutputFolder ds 'proliferation'];
TrackStruct.ProlDir=prol_dir;
mkdir(prol_dir);
TrackStruct.ProlFileRoot=[prol_dir ds 'prol'];
xls_folder=[root_folder ds 'spreadsheets'];
mkdir(xls_folder);
TrackStruct.ProlXlsFile=[xls_folder ds well_name '.csv'];
TrackStruct.ShapesXlsFile=[xls_folder ds well_name '_shapes.csv'];
TrackStruct.StartFrame=1;
TrackStruct.FrameCount=90;
TrackStruct.TimeFrame=.5; %minutes
TrackStruct.FrameStep=10; %read every x frames
TrackStruct.NumberFormat='%04d';

%toolbox struct
param=[];
param.mem=3;   % how many frames can a cell disappear for and still count towards a trajectory.
param.dim=2;   % don't change this value
param.good=10;   % minimum size (frames) of cell centroids to count as a valid trajectory.
param.quiet=0;   % make this one to suppress output, zero to show output.

TrackStruct.ToolboxParams=param;
TrackStruct.SearchRadius=40;
TrackStruct.Channel='';
TrackStruct.MinBlobArea=100;
TrackStruct.bContourLink=false;
TrackStruct.LinkDist=1;
TrackStruct.ObjectReduce=0.3;
TrackStruct.ClusterDist=5;
TrackStruct.bCytoLocalAvg=false;
TrackStruct.CytoBrightThreshold=1.05;
TrackStruct.bNuclLocalAvg=true;
TrackStruct.NuclBrightThreshold=1.05;
TrackStruct.bCytoGrad=true;
TrackStruct.CytoGradThreshold=2800;
TrackStruct.bNuclGrad=true;
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
TrackStruct.ApproxDist=4;
TrackStruct.ClearBorderDist=2;
TrackStruct.WatershedMed=7;

disp(TrackStruct)

cells_track(TrackStruct);
extract_movie_data(TrackStruct);
displayprolstats(TrackStruct);
%end function
end