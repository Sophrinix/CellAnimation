function breakTrack()
global mtr_gui_struct;

track_id=mtr_gui_struct.SelectedCellID;
if (track_id==0)
    warndlg('No cell is selected!');
    return;
end
cur_time=(mtr_gui_struct.CurFrame-1)*mtr_gui_struct.TimeFrame;
ancestry_layout=mtr_gui_struct.AncestryLayout;
ancestry_record=mtr_gui_struct.CurrentAncestryRecord;
if (cur_time==ancestry_record(ancestry_layout.StartTimeCol))
    warndlg('Can''t break a track at its start point!');
    return;
end
if (cur_time==ancestry_record(ancestry_layout.StopTimeCol))
    warndlg('Can''t break a track at its end point!');
    return;
end
ancestry_records=mtr_gui_struct.CellsAncestry;
new_track_id=max(ancestry_records(:,ancestry_layout.TrackIDCol))+1;
tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
new_track_idx=(tracks(:,tracks_layout.TrackIDCol)==track_id)&(tracks(:,tracks_layout.TimeCol)>=cur_time);
tracks(new_track_idx,tracks_layout.TrackIDCol)=new_track_id;
mtr_gui_struct.Tracks=tracks;

%add ancestry record
new_ancestry_record=zeros(1,size(ancestry_records,2));
new_ancestry_record(ancestry_layout.TrackIDCol)=new_track_id;
new_ancestry_record(ancestry_layout.StartTimeCol)=cur_time;
new_ancestry_record(ancestry_layout.StopTimeCol)=ancestry_record(ancestry_layout.StopTimeCol);
new_ancestry_record(ancestry_layout.GenerationCol)=1;
ancestry_records=[ancestry_records; new_ancestry_record];

%update the ancestry record of the old track
ancestry_idx=ancestry_records(:,ancestry_layout.TrackIDCol)==track_id;
ancestry_records(ancestry_idx,ancestry_layout.StopTimeCol)=cur_time-mtr_gui_struct.TimeFrame;
%find any children of the new track and update their parent ids
ancestry_idx=(ancestry_records(:,ancestry_layout.ParentIDCol)==track_id)&...
    (ancestry_records(:,ancestry_layout.StartTimeCol)>=cur_time);
ancestry_records(ancestry_idx,ancestry_layout.ParentIDCol)=new_track_id;
mtr_gui_struct.CellsAncestry=ancestry_records;
mtr_gui_struct.SelectedCellID=0;
mtr_gui_struct.SelectedCellLabelID=0;
updateTrackImage(mtr_gui_struct.CurFrame,mtr_gui_struct.ShowLabels,mtr_gui_struct.ShowOutlines);
addSelectionLayers();

%end breakTrack
end