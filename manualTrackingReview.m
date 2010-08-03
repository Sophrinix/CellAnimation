function output_args=manualTrackingReview(input_args)
global mtr_gui_struct;
mtr_gui_struct.TotalErrors=0;

%initialize the gui
field_names=fieldnames(mtr_gui_struct);
gui_handle=findall(0,'Tag','TrackingReview');
if (~isempty(gui_handle))    
    close(gui_handle);    
end
if (max(strcmp('FigurePosition',field_names)))
    mtr_gui_struct.GuiHandle=manualTrackingReviewGUI('Position',mtr_gui_struct.FigurePosition);
else
    mtr_gui_struct.GuiHandle=manualTrackingReviewGUI;    
end
gui_handle=mtr_gui_struct.GuiHandle;
children_handles=get(gui_handle,'children');
mtr_gui_struct.TracksHandle=findobj(children_handles,'tag','tracksAxes');
mtr_gui_struct.SliderHandle=findobj(children_handles,'tag','sliderTracks');
mtr_gui_struct.Tracks=input_args.Tracks.Value;
mtr_gui_struct.CellsAncestry=input_args.CellsAncestry.Value;
mtr_gui_struct.TimeFrame=input_args.TimeFrame.Value;
mtr_gui_struct.TracksLayout=input_args.TracksLayout.Value;
tracks_layout=mtr_gui_struct.TracksLayout;
mtr_gui_struct.TimeCol=tracks_layout.TimeCol;
mtr_gui_struct.TrackIDCol=tracks_layout.TrackIDCol;
mtr_gui_struct.MaxMissingFrames=input_args.MaxMissingFrames.Value;
mtr_gui_struct.FrameStep=input_args.FrameStep.Value;
mtr_gui_struct.ColorMap=input_args.ColorMap.Value;
mtr_gui_struct.AncestryLayout=input_args.AncestryLayout.Value;
mtr_gui_struct.FrameCount=input_args.FrameCount.Value;
mtr_gui_struct.ImageFileBase=input_args.ImageFileBase.Value;
mtr_gui_struct.NumberFormat=input_args.NumberFormat.Value;
mtr_gui_struct.ImgExt=input_args.ImgExt.Value;
mtr_gui_struct.SegFileRoot=input_args.SegFileRoot.Value;
[cell_speeds cell_sq_disps]=getMotilityParams(mtr_gui_struct.Tracks,mtr_gui_struct.TracksLayout,...
    mtr_gui_struct.CellsAncestry,mtr_gui_struct.AncestryLayout,mtr_gui_struct.TimeFrame);
mtr_gui_struct.CellSpeeds=cell_speeds;
mtr_gui_struct.CellSquareDisplacements=cell_sq_disps;
mtr_gui_struct.FrameMSDs=getFrameMSDs(cell_sq_disps,mtr_gui_struct.TimeFrame);
mtr_gui_struct.StatusTextHandle=findobj(children_handles,'tag','statusText');
mtr_gui_struct.EditStatus1Handle=findobj(children_handles,'tag','editStatus1');
mtr_gui_struct.EditStatus2Handle=findobj(children_handles,'tag','editStatus2');
mtr_gui_struct.EditStatus3Handle=findobj(children_handles,'tag','editStatus3');
mtr_gui_struct.EditCellStatusHandle=findobj(children_handles,'tag','editStatusCell');
mtr_gui_struct.CheckBoxLabelsHandle=findobj(children_handles,'tag','checkboxLabels');
mtr_gui_struct.CheckBoxOutlinesHandle=findobj(children_handles,'tag','checkboxShowOutlines');
mtr_gui_struct.ButtonContinueTrackHandle=findobj(children_handles,'tag','buttonContinueTrack');
mtr_gui_struct.ButtonRemoveSplitHandle=findobj(children_handles,'tag','buttonRemoveSplit');
mtr_gui_struct.ButtonAddSplitHandle=findobj(children_handles,'tag','buttonAddSplit');
mtr_gui_struct.AveragesTextHandle=findobj(children_handles,'tag','textAverages');
cur_frame=1;
mtr_gui_struct.CurFrame=cur_frame;
mtr_gui_struct.SelectedCellID=0;
mtr_gui_struct.SelectedCellLabelID=0;
mtr_gui_struct.ShowLabels=get(mtr_gui_struct.CheckBoxLabelsHandle,'Value');
mtr_gui_struct.ShowOutlines=get(mtr_gui_struct.CheckBoxOutlinesHandle,'Value');
mtr_gui_struct.ContinueTrack=false;
mtr_gui_struct.SplitTrack=false;
mtr_gui_struct.SwitchTrack=false;
mtr_gui_struct.SelectionLayers={};

set(mtr_gui_struct.SliderHandle,'Min',cur_frame);
set(mtr_gui_struct.SliderHandle,'Max',mtr_gui_struct.FrameCount);
set(mtr_gui_struct.SliderHandle,'Value',cur_frame);
slider_step_size=1.0/double(mtr_gui_struct.FrameCount);
set(mtr_gui_struct.SliderHandle,'SliderStep',[slider_step_size min([10*slider_step_size 1])]);
%turn off the axes
set(mtr_gui_struct.GuiHandle,'DefaultAxesVisible','off');
set(mtr_gui_struct.StatusTextHandle,'String', ' Frame: 1 Mitotic Events Detected: 0');
set(mtr_gui_struct.EditStatus1Handle,'String', 'New Cells From Split:');
set(mtr_gui_struct.EditStatus2Handle,'String', 'Other New Cells In Frame:');
mtr_gui_struct.AveragesText=displayCellAverages();
displayFrameMSD();
updateTrackImage(cur_frame,mtr_gui_struct.ShowLabels,mtr_gui_struct.ShowOutlines);
mtr_gui_struct.CurCentroids=getApproximateCentroids(mtr_gui_struct.CellsLabel);
%block execution until gui is closed
waitfor(gui_handle);
output_args.LabelMatrix=msr_gui_struct.ObjectsLabel;

%end manualTrackingReview
end

function frame_msds=getFrameMSDs(square_disps,time_frame)

max_time_frame=max(square_disps(:,3));
nr_frames=max_time_frame/time_frame+1;
frame_msds=zeros(nr_frames,1);
for i=2:nr_frames
    cur_time=(i-1)*time_frame;
    frame_msds(i)=mean(square_disps(square_disps(:,3)==cur_time,2));
end

%getFrameMSDs
end

function [cell_speeds square_disps]=getMotilityParams(tracks,tracks_layout,ancestry_records,ancestry_layout,time_frame)

tracks_nr=max(ancestry_records(:,ancestry_layout.TrackIDCol));
cell_speeds=zeros(size(tracks,1),3);
square_disps=cell_speeds;
for i=1:tracks_nr
    cur_track_idx=tracks(:,tracks_layout.TrackIDCol)==i;
    track_centroids=tracks(cur_track_idx,tracks_layout.Centroid1Col:tracks_layout.Centroid2Col);    
    if isempty(track_centroids)
        continue;
    end    
    cur_dist=hypot(track_centroids(1:(end-1),1)-track_centroids(2:end,1),track_centroids(1:(end-1),2)-track_centroids(2:end,2));
    cell_speeds(cur_track_idx,2)=[0; cur_dist]./time_frame;
    cell_speeds(cur_track_idx,1)=i;
    cell_speeds(cur_track_idx,3)=tracks(cur_track_idx,tracks_layout.TimeCol);
    square_disps(cur_track_idx,2)=cumsum([0; cur_dist.^2]);
    square_disps(cur_track_idx,1)=i;
    square_disps(cur_track_idx,3)=tracks(cur_track_idx,tracks_layout.TimeCol);
end

%end getMotilityParams
end

function averages_text=displayCellAverages()
global mtr_gui_struct;

tracks=mtr_gui_struct.Tracks;
tracks_layout=mtr_gui_struct.TracksLayout;
cell_speeds=mtr_gui_struct.CellSpeeds;
cell_areas=tracks(:,tracks_layout.AreaCol);
mean_area=mean(cell_areas);
averages_text=['Cell Averages: Area ' num2str(mean_area)];
cell_ecc=tracks(:,tracks_layout.EccCol);
mean_ecc=mean(cell_ecc);
averages_text=[averages_text ' Eccentricity ' num2str(mean_ecc)];
cell_per=tracks(:,tracks_layout.PerCol);
mean_per=mean(cell_per);
averages_text=[averages_text ' Perimeter ' num2str(mean_per)];
cell_sol=tracks(:,tracks_layout.SolCol);
mean_sol=mean(cell_sol);
averages_text=[averages_text ' Solidity ' num2str(mean_sol)];
mean_speed=mean(cell_speeds(cell_speeds(:,2)>0,2));
averages_text=[averages_text ' Speed ' num2str(mean_speed)];
set(mtr_gui_struct.AveragesTextHandle,'String',averages_text);

%end displayCellAverages
end