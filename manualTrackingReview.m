function output_args=manualTrackingReview(input_args)
%Usage
%The manual tracking review module can be used to correct errors in automatic tracking and
%as a visualization module to select subsets of tracks based on speed, motility and ancestry
%parameters. For track correction there are six actions that can be performed: continue a track,
%switch tracks, delete a track, break a track, add a split and remove a split. The GUI displays
%population statistics at the top under the menu bar and individual cell statistics (if a cell is
%selected) in a text box on the right side. Detected cell outlines and cell IDs may be displayed by
%checking the “Outlines” and/or “Labels” checkboxes.
%
%Track continuation can be used when automatic tracking loses a cell it is tracking and starts a
%new track for that same cell. To continue the pre-existing track with the new track, select the
%pre-existing track. Selecting a track is done by clicking the on the cell body. After selecting the
%pre-existing track, click on the “Continue Track” button, navigate to a frame where the new track
%exists and click on the cell body again to select it. The new track is then appended to the pre-
%existing track. To see the updated track navigate to another frame.
%
%Switching tracks can be used to correct errors resulting from tracks being switched from one
%cell to the other during automatic tracking. To switch the tracks navigate to the frame where
%the error occurs click on the first cell, click on the “Switch tracks” button and finally click on the
%second cell. To see the updated tracks navigate to another frame.
%
%To erase a track select it then click on the “Delete Track” button.
%
%Breaking a track splits the track in two at the current frame. The newly created track starts at
%the current frame and the old track ends at the frame before that. This can be used to correct
%complex errors by separating a track into smaller segments than using the other actions to fix
%the automatic tracking errors.
%
%Errors in mitotic event detection can be corrected using the “Add Split” and “Remove Split”
%buttons. To correct a missed mitotic event select click on the parent cell (the cell with the older
%track), click on “Add Split” button then click on the second cell that is part of the mitotic event.
%The older track is broken at the current frame, a new track is created and the ancestry records
%are updated for all three tracks. To remove a spurious mitotic event select the track you want to
%use to continue the parent track, and then click on the “Remove Split” button. The new track is
%merged with the parent track and the ancestry records are updated for both the parent track and
%the other remaining track.
%
%The visualization part of the GUI is controlled using the “Manage Selection Layers” button.
%A selection layer is a transparency overlaid on the original image that highlights certain cells
%based on a user-defined criterion. The criterion for comparison may be an exact value (such as
%all cells with an area larger than 500 square pixels) or a percentage (cells with an area in the
%top 20%). Any combination of shape, motility and ancestry parameters may be used alone or in
%combination to define a layer. This allows the user to define layers that are either very broad in
%scope, such as all cells that are larger than average in a movie, or extremely tailored, such as
%selection for small, rounded, fast cells with a specific parent ID. Multiple layers may be present
%at one time and, due to the use of transparencies and a broad selection of layer colors, cells
%that are part of multiple layers can be detected. The layers are automatically updated as the
%user moves backward or forward through the timelapse sequence, and the resulting images
%themselves may be saved.
%
%To define a selection layer click on the “Manage Selection Layers” button then click the “Add
%Layer” button. Type in the name of the layer, select a layer color from the dropdown box,
%then add a number of conditions. Conditions may be combined using “AND” and “OR” logical
%connectors. A condition consists of a property such as “Area” or “Cell ID” an operation
%(“=”,”<”,”>” are supported) and a value. The value can be either an absolute number or a
%percentage. Once all the conditions have been set click the “Save Layer” button, then close the
%selection layers GUI to apply the layer. To delete a layer click on “Manage Selection Layers”
%then select the layer to be removed and click on the “Remove Layer” button.
%
%Input Structure Members
%AncestryLayout – Matrix describing the order of the columns in the tracks matrix.
%CellsAncestry – Matrix containing cell ancestry records.
%ColorMap – Color map to be used in drawing the cell outlines for each generation. Each
%generation will use the next color in the color map until all colors have been used. Afterwards,
%the colors in the map are recycled.
%FirstFrameIDs – The IDs of tracks starting in the first frame.
%FrameCount – The number of frames to track.
%FrameStep – Read one out of every x frames when reading the image set. Default value is one
%meaning every frame will be read.
%ImageFileBase – The root file name of the images in the sequence. For example, if the image
%names in the time-lapse sequence are “Experiment-0002_Position(8)_t001.jpg”,”Experiment-
%0002_Position(8)_t002.jpg”, etc., the root image file name is “Experiment-0002_Position(8)_t”.
%ImgExt – String indicating the image file extension. Usually, “.jpg” or “.tif”.
%MaxMissingFrames – This value indicates if tracks not present in the current frame should be
%included in the track subset and if so how many frames away from the current frame a track is
%allowed to be and still be included in the subset.
%NumberFormat – A string indicating the number format of the file name to be used when saving
%the overlayed image.
%SegFileRoot – The root of the data file name containing the segmented objects.
%StartFrame – Integer indicating at which frame the tracking should start.
%SplitCells – The IDs of tracks that are the result of mitosis.
%TimeCol – The index of the time column in the tracks matrix.
%TimeFrame – Time interval between consecutive frames.
%TrackIDCol – The index of the track ID column in the tracks matrix.
%TrackIDs – The IDs of all the tracks.
%Tracks – The matrix containing all the tracks (track IDs and shape parameters for every cell at
%every time point).
%TracksLayout – Matrix describing the order of the columns in the tracks matrix.
%
%Output Structure Members
%CellsAncestry – Matrix containing corrected cell ancestry records.
%Tracks – The matrix containing all the corrected tracks (track IDs and shape parameters for
%every cell at every time point).
%
%Example
%
%manual_tracks_review_function.InstanceName='ManualTracksReview';
%manual_tracks_review_function.FunctionHandle=@manualTrackingReview;
%manual_tracks_review_function.FunctionArgs.Tracks.FunctionInstance='LoadTrack
%s';
%manual_tracks_review_function.FunctionArgs.Tracks.OutputArg='tracks';
%manual_tracks_review_function.FunctionArgs.CellsAncestry.FunctionInstance='Lo
%adAncestry';
%manual_tracks_review_function.FunctionArgs.CellsAncestry.OutputArg='cells_anc
%estry';
%manual_tracks_review_function.FunctionArgs.ColorMap.FunctionInstance='LoadCol
%ormap';
%manual_tracks_review_function.FunctionArgs.ColorMap.OutputArg='cmap';
%manual_tracks_review_function.FunctionArgs.ImageFileBase.Value=TrackStruct.Im
%ageFileBase;
%manual_tracks_review_function.FunctionArgs.NumberFormat.Value=TrackStruct.Num
%berFormat;
%manual_tracks_review_function.FunctionArgs.ImgExt.Value=TrackStruct.ImgExt;
%manual_tracks_review_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFr
%ame;
%manual_tracks_review_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCo
%l;
%manual_tracks_review_function.FunctionArgs.TrackIDCol.Value=tracks_layout.Tra
%ckIDCol;
%manual_tracks_review_function.FunctionArgs.MaxMissingFrames.Value=TrackStruct
%.MaxFramesMissing;
%manual_tracks_review_function.FunctionArgs.FrameStep.Value=TrackStruct.FrameS
%tep;
%manual_tracks_review_function.FunctionArgs.TracksLayout.Value=tracks_layout;
%manual_tracks_review_function.FunctionArgs.SegFileRoot.Value=TrackStruct.SegF
%ileRoot;
%manual_tracks_review_function.FunctionArgs.AncestryLayout.Value=ancestry_layo
%
%ut;
%manual_tracks_review_function.FunctionArgs.FrameCount.Value=TrackStruct.Frame
%Count;
%manual_tracks_review_function.FunctionArgs.StartFrame.Value=TrackStruct.Start
%Frame;
%
%…
%
%save_updated_tracks_function.InstanceName='SaveUpdatedTracks';
%save_updated_tracks_function.FunctionHandle=@saveTracks;
%save_updated_tracks_function.FunctionArgs.Tracks.FunctionInstance='ManualTrac
%ksReview';
%save_updated_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
%save_updated_tracks_function.FunctionArgs.TracksFileName.Value=[TrackStruct.P
%rolDir ds 'tracks.mat'];
%
%save_ancestry_function.InstanceName='SaveAncestry';
%save_ancestry_function.FunctionHandle=@saveAncestry;
%save_ancestry_function.FunctionArgs.CellsAncestry.FunctionInstance='ManualTra
%cksReview';
%save_ancestry_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
%save_ancestry_function.FunctionArgs.AncestryFileName.Value=[TrackStruct.ProlD
%ir ds 'ancestry.mat'];


global mtr_gui_struct;
mtr_gui_struct=[];
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
mtr_gui_struct.StartFrame=input_args.StartFrame.Value;
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
cur_frame=mtr_gui_struct.StartFrame;
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
set(mtr_gui_struct.SliderHandle,'Max',mtr_gui_struct.FrameCount+cur_frame);
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
output_args.Tracks=mtr_gui_struct.Tracks;
output_args.CellsAncestry=mtr_gui_struct.CellsAncestry;

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
    total_dist=cumsum(cur_dist);
    cell_speeds(cur_track_idx,2)=[0; cur_dist]./time_frame;
    cell_speeds(cur_track_idx,1)=i;
    cell_speeds(cur_track_idx,3)=tracks(cur_track_idx,tracks_layout.TimeCol);
    square_disps(cur_track_idx,2)=(track_centroids(:,1)-track_centroids(1,1)).^2+(track_centroids(:,2)-track_centroids(1,2)).^2;
    square_disps(cur_track_idx,1)=i;
    square_disps(cur_track_idx,3)=tracks(cur_track_idx,tracks_layout.TimeCol);
end

%end getMotilityParams
end

function averages_text=displayCellAverages()
global mtr_gui_struct;
str_fmt='%1.2f';

tracks=mtr_gui_struct.Tracks;
tracks_layout=mtr_gui_struct.TracksLayout;
cell_speeds=mtr_gui_struct.CellSpeeds;
cell_areas=tracks(:,tracks_layout.AreaCol);
mean_area=mean(cell_areas);
averages_text=['Cell Averages: Area ' num2str(mean_area,str_fmt)];
cell_ecc=tracks(:,tracks_layout.EccCol);
mean_ecc=mean(cell_ecc);
averages_text=[averages_text ' Eccentricity ' num2str(mean_ecc,str_fmt)];
cell_per=tracks(:,tracks_layout.PerCol);
mean_per=mean(cell_per);
averages_text=[averages_text ' Perimeter ' num2str(mean_per,str_fmt)];
cell_sol=tracks(:,tracks_layout.SolCol);
mean_sol=mean(cell_sol);
averages_text=[averages_text ' Solidity ' num2str(mean_sol,str_fmt)];
mean_speed=mean(cell_speeds(cell_speeds(:,2)>0,2));
averages_text=[averages_text ' Speed ' num2str(mean_speed,str_fmt)];
set(mtr_gui_struct.AveragesTextHandle,'String',averages_text);

%end displayCellAverages
end
