function []=darren_fl_20091007_track(well_folder)
TrackStruct=[];
TrackStruct.ImgExt='.tif';
ds='\'  %directory symbol
TrackStruct.DS=ds;
root_folder='c:\darren';
TrackStruct.ImageFileName='DsRed - Confocal - n';
%low hepsin expressing - not really wildtype
TrackStruct.ImageFileBase=[well_folder ds TrackStruct.ImageFileName];
%hepsin overexpressing
% TrackStruct.ImageFileBase=[well_folder ds 'llh_hep_lm7_t'];
TrackStruct.StartFrame=1;
TrackStruct.FrameCount=15;
TrackStruct.TimeFrame=15; %minutes
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
TrackStruct.MinCytoArea=60;
TrackStruct.MinNuclArea=60;
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

%for thresholding filters one needs to specify a FilterStruct array for each
%filter applied. the filter struct specifies the filter function name as
%well as any parameters that filter requires. in addition the way each
%image is combined with the result from other filter is specified. filters
%will be run in the order in which they are present in the filter array

%'Brightness Local Averaging Filter' - start
filterLocalAverageStruct.Name='Brightness Local Averaging Filter';
filterLocalAverageStruct.FilterFunctionHandle=@generateBinImgUsingLocAvg;
%what image to use for filter input: 0 is image as it is before any thresholding
%filters 1 is the image resulting from first thresholding filter and so on
filterLocalAverageStruct.SourceImageOrder=0;
%what logical operation to use to combine the results from this filter with
%the result from the previous filters.
filterLocalAverageStruct.CombineWithPrevFilter='OR';
%structural element for average filter
parametersLocalAverageFilterStruct.strel='disk';
%structural element size
parametersLocalAverageFilterStruct.strelSize=10;
%local average percentage brightness threshold
parametersLocalAverageFilterStruct.BrightnessThresholdPct=1.1;
%erase objects at the image border?
parametersLocalAverageFilterStruct.bClearBorder=true;
%how far from the border are we erasing objects?
parametersLocalAverageFilterStruct.clearBorderDist=2;
%set the filter params
filterLocalAverageStruct.filterParams=parametersLocalAverageFilterStruct;
%'Brightness Local Averaging Filter' - end

%'Global Pixel Intensity Filter' - start
filterGlobalPixelIntensityStruct.Name='Global Pixel Intensity Filter';
%handle to the filter function
filterGlobalPixelIntensityStruct.FilterFunctionHandle=@generateBinImgUsingGlobInt;
%what image to use for filter input: 0 is image as it is before any thresholding
%filters 1 is the image resulting from first thresholding filter and so on
filterGlobalPixelIntensityStruct.SourceImageOrder=0;
%what logical operation to use to combine the results from this filter with
%the result from the previous filters.
filterGlobalPixelIntensityStruct.CombineWithPrevFilter='AND';
%pixels that are below this percentage of average max intensity will be set to zero in the binary
%image
parametersGlobalPixelIntensityStruct.IntensityThresholdPct=0.1;
%erase objects at the image border?
parametersGlobalPixelIntensityStruct.bClearBorder=true;
%how far from the border are we erasing objects?
parametersGlobalPixelIntensityStruct.clearBorderDist=2;
%set the filter params
filterGlobalPixelIntensityStruct.filterParams=parametersGlobalPixelIntensityStruct;
%'Global Pixel Intensity Filter' - end

cytoThresholdingFilterArray{1}=filterLocalAverageStruct;
cytoThresholdingFilterArray{2}=filterGlobalPixelIntensityStruct;
%filters used to create the binary cytoplasm image
TrackStruct.CytoThresholdingFilters=cytoThresholdingFilterArray;

%filters used to create the binary nuclei image
nuclThresholdingFilterArray=cytoThresholdingFilterArray;
nuclThresholdingFilterArray{1}.filterParams.BrightnessThresholdPct=1.1;
TrackStruct.NuclThresholdingFilters=nuclThresholdingFilterArray;

disp(TrackStruct)

cells_track(TrackStruct);
validate_tracks(TrackStruct);
%end function
end