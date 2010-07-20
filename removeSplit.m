function removeSplit()
global mtr_gui_struct;

ancestry_layout=mtr_gui_struct.AncestryLayout;
daughter_ancestry_record=mtr_gui_struct.CurrentAncestryRecord;
parent_id=daughter_ancestry_record(ancestry_layout.ParentIDCol);
if (parent_id==0)
    warndlg('This cell is not the result of a split!');
    return;
end
cell_start_frame=daughter_ancestry_record(ancestry_layout.StartTimeCol);
if (cell_start_frame~=((mtr_gui_struct.CurFrame-1)*mtr_gui_struct.TimeFrame))
    warndlg('This cell is not the result of a split in this frame!');
    return;
end
tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
daughter_id=mtr_gui_struct.SelectedCellID;
remove_track_idx=daughter_id==tracks(:,tracks_layout.TrackIDCol);
%remove this daughter cell and use it to continue the former parent cell
tracks(remove_track_idx,tracks_layout.TrackIDCol)=parent_id;
mtr_gui_struct.Tracks=tracks;
%update current track record
current_track_record=mtr_gui_struct.CurrentTrackRecord;
current_track_record(tracks_layout.TrackIDCol)=parent_id;
mtr_gui_struct.CurrentTrackRecord=current_track_record;
%downgrade the generation number for all the daughter cells and all their
%children
offsetGenerationNumber(parent_id);
ancestry_records=mtr_gui_struct.AncestryRecords;
%update the ancestry record of the parent cell with the new stop time
parent_ancestry_idx=ancestry_records(:,ancestry_layout.TrackIDCol)==parent_id;
ancestry_records(parent_ancestry_idx,ancestry_layout.StopTimeCol)=...
    daughter_ancestry_record(ancestry_layout.StopTimeCol);
mtr_gui_struct.CurrentAncestryRecord=ancestry_records(parent_ancestry_idx,:);
%update the parent ids of any remaining daughter cells
daughters_idx=ancestry_records(:,ancestry_layout.ParentIDCol)==parent_id;
ancestry_records(daughters_idx,ancestry_layout.ParentIDCol)=0;
mtr_gui_struct.AncestryRecords=ancestry_records;
updateCellStatus();

%end removeSplit
end

function offsetGenerationNumber(parent_id)
global mtr_gui_struct;

ancestry_records=mtr_gui_struct.CellsAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
daughters_idx=ancestry_records(:,ancestry_layout.ParentIDCol)==parent_id;
daughter_ids=ancestry_records(daughters_idx,ancestry_layout.TrackIDCol);
if (isempty(daughter_ids))
    return;
end
ancestry_records(daughters_idx,ancestry_layout.GenerationCol)=...
    ancestry_records(daughters_idx,ancestry_layout.GenerationCol)-1;
mtr_gui_struct.AncestryRecords=ancestry_records;
%recurse for all the daughters
for i=1:length(daughter_ids)
    offsetGenerationNumber(daughter_ids(i));
end

%end offsetGenerationNumber
end