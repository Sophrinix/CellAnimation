function sliderTracksEvent()
%manual tracking review module. track slider event handler
global mtr_gui_struct;

cur_frame=round(get(mtr_gui_struct.SliderHandle,'Value'));
mtr_gui_struct.CurFrame=cur_frame;
[mitotic_cells_ids other_new_cells_ids mitotic_events_nr]=getMitoticEventsIDs(cur_frame);
status_text=[' Frame: ' num2str(cur_frame) ' Mitotic Events Detected: ' num2str(mitotic_events_nr)];
set(mtr_gui_struct.StatusTextHandle,'String', status_text);
status_text=['New Cells From Split: ' num2str(mitotic_cells_ids')];
set(mtr_gui_struct.EditStatus1Handle,'String', status_text);
status_text=['Other New Cells In Frame: ' num2str(other_new_cells_ids')];
set(mtr_gui_struct.EditStatus2Handle,'String', status_text);
updateTrackImage(cur_frame,mtr_gui_struct.ShowLabels,mtr_gui_struct.ShowOutlines);
mtr_gui_struct.CurCentroids=getApproximateCentroids(mtr_gui_struct.CellsLabel);
addSelectionLayers();
displayFrameMSD();
if (mtr_gui_struct.SelectedCellID&&(cur_frame>=mtr_gui_struct.SelectedCellStart)...
        &&(cur_frame<=mtr_gui_struct.SelectedCellEnd))
    updateTrackRecord();    
    mtr_gui_struct.SelectedCellLabelID=getCurLabelID();
    selectCell(mtr_gui_struct.SelectedCellLabelID);    
    updateCellStatus();
end

%end sliderTracksEvent
end

function updateTrackRecord()

global mtr_gui_struct;

tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
cur_time=(mtr_gui_struct.CurFrame-1)*mtr_gui_struct.TimeFrame;
cur_tracks_idx=tracks(:,tracks_layout.TimeCol)==cur_time;
cur_tracks=tracks(cur_tracks_idx,:);
cur_cell_idx=cur_tracks(:,tracks_layout.TrackIDCol)==mtr_gui_struct.SelectedCellID;
cur_track_record=cur_tracks(cur_cell_idx,:);
mtr_gui_struct.CurrentTrackRecord=cur_track_record;
cell_speeds=mtr_gui_struct.CellSpeeds;
cur_speeds=cell_speeds(cur_tracks_idx,2);
cell_sq_disps=mtr_gui_struct.CellSquareDisplacements;
cur_sq_disps=cell_sq_disps(cur_tracks_idx,2);

mtr_gui_struct.CurrentSpeed=cur_speeds(cur_cell_idx);
mtr_gui_struct.CurrentSquareDisplacement=cur_sq_disps(cur_cell_idx);

%end updateTrackRecord
end

function [mitotic_cells_ids other_new_cells_ids mitotic_events_nr]=getMitoticEventsIDs(frame_nr)
global mtr_gui_struct;

ancestry_records=mtr_gui_struct.CellsAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
time_frame=mtr_gui_struct.TimeFrame;
cur_time=(frame_nr-1).*time_frame;
new_cells_idx=ancestry_records(:,ancestry_layout.StartTimeCol)==cur_time;
mitotic_events_idx=ancestry_records(:,ancestry_layout.ParentIDCol)>0;
mitotic_cells_ids=ancestry_records(new_cells_idx&mitotic_events_idx,ancestry_layout.TrackIDCol);
other_new_cells_ids=ancestry_records(new_cells_idx&(~mitotic_events_idx),ancestry_layout.TrackIDCol);
mitotic_events_nr=size(mitotic_cells_ids,1)/2;

%end getNumberOfMitoticEvents
end

function label_id=getCurLabelID()
global mtr_gui_struct;

tracks_layout=mtr_gui_struct.TracksLayout;
cur_track_record=mtr_gui_struct.CurrentTrackRecord;
if (isempty(cur_track_record))
    label_id=-1;
    return;
end
cell_centroid=cur_track_record(:,tracks_layout.Centroid1Col:tracks_layout.Centroid2Col);
cur_centroids=mtr_gui_struct.CurCentroids;
cur_dist=hypot(cell_centroid(1)-cur_centroids(:,1),cell_centroid(2)-cur_centroids(:,2));
[dummy label_id]=min(cur_dist);

%end getCurLabelID
end