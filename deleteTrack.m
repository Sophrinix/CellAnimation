function deleteTrack()
global mtr_gui_struct;

track_id=mtr_gui_struct.SelectedCellID;
tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
mtr_gui_struct.SelectedCellID=0;
mtr_gui_struct.SelectedCellLabelID=0;
%remove track
track_idx=tracks(:,tracks_layout.TrackIDCol)==track_id;
tracks(track_idx,:)=[];
mtr_gui_struct.Tracks=tracks;
%update ancestry records
ancestry_records=mtr_gui_struct.CellsAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
ancestry_idx=ancestry_records(:,ancestry_layout.TrackIDCol)==track_id;
ancestry_records(ancestry_idx,:)=[];
mtr_gui_struct.CellsAncestry=ancestry_records;
offsetGenerationNumber(track_id,-1);
updateTrackImage(mtr_gui_struct.CurFrame,mtr_gui_struct.ShowLabels,mtr_gui_struct.ShowOutlines);
addSelectionLayers();

%end deleteTrack
end