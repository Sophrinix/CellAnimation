function mouseClickInTrackingFrame()
global mtr_gui_struct;

axes_handle=mtr_gui_struct.TracksHandle;
original_axes_units=get(axes_handle,'Units');
set(axes_handle,'Units','Pixels');
click_point = get(axes_handle,'CurrentPoint');
set(axes_handle,'Units',original_axes_units);
cells_lbl=mtr_gui_struct.CellsLabel;
cur_cell_lbl_id=cells_lbl(round(click_point(1,2)),round(click_point(1,1)));
if ((cur_cell_lbl_id==0)||(mtr_gui_struct.SelectedCellLabelID==cur_cell_lbl_id))
    hold off;
    mtr_gui_struct.SelectedCellID=0;
    mtr_gui_struct.SelectedCellLabelID=0;
    mtr_gui_struct.ImageHandle=image(mtr_gui_struct.ImageData,'Parent',mtr_gui_struct.TracksHandle);
    %set the function handle for a mouse click in the objects image
    set(mtr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInTrackingFrame');
    set(mtr_gui_struct.ButtonContinueTrackHandle,'Enable','off');
    set(mtr_gui_struct.ButtonRemoveSplitHandle,'Enable','off');
    set(mtr_gui_struct.ButtonAddSplitHandle,'Enable','off');
else
    selectCell(cur_cell_lbl_id);
    mtr_gui_struct.SelectedCellLabelID=cur_cell_lbl_id;
    cell_id=getCellIDFromLabelID();
    mtr_gui_struct.SelectedCellID=cell_id;
    cell_ancestries=mtr_gui_struct.CellsAncestry;
    ancestry_layout=mtr_gui_struct.AncestryLayout;
    ancestry_record=cell_ancestries(cell_ancestries(:,ancestry_layout.TrackIDCol)==cell_id,:);
    mtr_gui_struct.SelectedCellStart=(ancestry_record(ancestry_layout.StartTimeCol)./mtr_gui_struct.TimeFrame)+1;
    mtr_gui_struct.SelectedCellEnd=(ancestry_record(ancestry_layout.StopTimeCol)./mtr_gui_struct.TimeFrame)+1;
    mtr_gui_struct.CurrentAncestryRecord=ancestry_record;
    updateCellStatus();
    if (mtr_gui_struct.ContinueTrack)
        continue_id=mtr_gui_struct.TrackToContinueID;
        if (cell_id==continue_id)
            mtr_gui_struct.TrackToContinueID=[];
            mtr_gui_struct.TrackToContinueRecord=[];
            mtr_gui_struct.TrackToContinueAncestry=[];
            mtr_gui_struct.ContinueTrack=false;
            warndlg('You cannot continue the track using this track!');            
        end
        completeContinueTrack();
    elseif (mtr_gui_struct.SplitTrack)
        split_id=mtr_gui_struct.TrackToSplitID;
        if (cell_id==split_id)
            mtr_gui_struct.TrackToSplitID=[];
            mtr_gui_struct.TrackToSplitRecord=[];
            mtr_gui_struct.TrackToSplitAncestry=[];
            mtr_gui_struct.SplitTrack=false;
            warndlg('You cannot complete the split with this track!');            
        end
        completeSplitTrack();
    elseif (mtr_gui_struct.SwitchTrack)
        split_id=mtr_gui_struct.TrackToSplitID;
        if (cell_id==split_id)
            mtr_gui_struct.TrackToSwitchID=[];
            mtr_gui_struct.TrackToSwitchRecord=[];
            mtr_gui_struct.TrackToSwitchAncestry=[];
            mtr_gui_struct.SwitchTrack=false;
            warndlg('You cannot complete the switch with this track!');            
        end
        completeSwitchTrack();
    else
        set(mtr_gui_struct.ButtonContinueTrackHandle,'Enable','on');
        set(mtr_gui_struct.ButtonRemoveSplitHandle,'Enable','on');
        set(mtr_gui_struct.ButtonAddSplitHandle,'Enable','on');
    end
end


%end mouseClickInTrackingFrame
end

function completeSwitchTrack()
global mtr_gui_struct;

track1_id=mtr_gui_struct.SelectedCellID;
track2_id=mtr_gui_struct.SwitchTrackID;
cur_frame=mtr_gui_struct.CurFrame;
cur_time=(cur_frame-1).*mtr_gui_struct.TimeFrame;
tracks=mtr_gui_struct.Tracks;
tracks_layout=mtr_gui_struct.TracksLayout;
track_1_idx=(tracks(:,tracks_layout.TrackIDCol)==track1_id)&(tracks(:,tracks_layout.TimeCol)>=cur_time);
track_2_idx=(tracks(:,tracks_layout.TrackIDCol)==track2_id)&(tracks(:,tracks_layout.TimeCol)>=cur_time);
tracks(track_1_idx,tracks_layout.TrackIDCol)=track2_id;
tracks(track_2_idx,tracks_layout.TrackIDCol)=track1_id;
mtr_gui_struct.Tracks=tracks;
track1_ancestry_record=mtr_gui_struct.CurrentAncestryRecord;
track2_ancestry_record=mtr_gui_struct.SwitchTrackAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
ancestry_records=mtr_gui_struct.CellsAncestry;
track_1_idx=ancestry_records(:,ancestry_layout.TrackIDCol)==track1_id;
ancestry_records(track_1_idx,ancestry_layout.StopTimeCol)=...
    track2_ancestry_record(ancestry_layout.StopTimeCol);
track_2_idx=ancestry_records(:,ancestry_layout.TrackIDCol)==track2_id;
ancestry_records(track_2_idx,ancestry_layout.StopTimeCol)=...
    track1_ancestry_record(ancestry_layout.StopTimeCol);
track_1_children_idx=ancestry_records(:,ancestry_layout.ParentIDCol)==track1_id;
track_2_children_idx=ancestry_records(:,ancestry_layout.ParentIDCol)==track2_id;
ancestry_records(track_1_children_idx,ancestry_layout.ParentIDCol)=track2_id;
ancestry_records(track_2_children_idx,ancestry_layout.ParentIDCol)=track1_id;
mtr_gui_struct.CellsAncestry=ancestry_records;
mtr_gui_struct.SelectedCellID=track2_id;
mtr_gui_struct.SwitchTrackID=[];
mtr_gui_struct.SwitchTrackRecord=[];
mtr_gui_struct.SwitchTrackAncestry=[];
mtr_gui_struct.SwitchTrack=false;
updateCellStatus();

%end completeSwitchTrack
end

function completeSplitTrack()
global mtr_gui_struct;

ancestry_layout=mtr_gui_struct.AncestryLayout;
new_cell_ancestry=mtr_gui_struct.CurrentAncestryRecord;
new_cell_start_frame=(new_cell_ancestry(ancestry_layout.StartTimeCol)./mtr_gui_struct.TimeFrame)+1;
if (new_cell_start_frame~=mtr_gui_struct.CurFrame)
    mtr_gui_struct.TrackToSplitID=[];
    mtr_gui_struct.TrackToSplitRecord=[];
    mtr_gui_struct.TrackToSplitAncestry=[];
    mtr_gui_struct.SplitTrack=false;
    warndlg('This is not a new track in this frame!');
end
parent_id=new_cell_ancestry(ancestry_layout.ParentIDCol);
if (parent_id~=0)
    mtr_gui_struct.TrackToSplitID=[];
    mtr_gui_struct.TrackToSplitRecord=[];
    mtr_gui_struct.TrackToSplitAncestry=[];
    mtr_gui_struct.SplitTrack=false;
    warndlg('This track is the result of a split. You need to remove that split first!');
end
parent_ancestry=mtr_gui_struct.TrackToSplitAncestry;
parent_id=parent_ancestry(ancestry_layout.TrackIDCol);
new_cell_ancestry(ancestry_layout.ParentIDCol)=parent_id;
second_new_cell_ancestry=parent_ancestry;
second_new_cell_ancestry(ancestry_layout.ParentIDCol)=parent_id;
cur_time=new_cell_ancestry(ancestry_layout.StartTimeCol);
second_new_cell_ancestry(ancestry_layout.StartTimeCol)=cur_time;    
ancestry_records=mtr_gui_struct.CellsAncestry;
max_cell_id=max(ancestry_records(:,ancestry_layout.TrackIDCol));
second_new_cell_ancestry(ancestry_layout.TrackIDCol)=(max_cell_id+1);
parent_ancestry(ancestry_layout.StopTimeCol)=...
    cur_time-mtr_gui_struct.TimeFrame;
ancestry_records=mtr_gui_struct.CellsAncestry;
parent_ancestry_idx=ancestry_records(:,ancestry_layout.TrackIDCol)==parent_id;
ancestry_records(parent_ancestry_idx,:)=parent_ancestry;
new_cell_ancestry_idx=ancestry_records(:,ancestry_layout.TrackIDCol)...
    ==mtr_gui_struct.SelectedCellID;
ancestry_records(new_cell_ancestry_idx,:)=new_cell_ancestry;
ancestry_records=[ancestry_records; second_new_cell_ancestry];
mtr_gui_struct.CellsAncestry=ancestry_records;
tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
second_new_track_idx=(tracks(:,tracks_layout.TrackIDCol)==parent_id)&...
    (tracks(:,tracks_layout.TimeCol)>=cur_time);
tracks(second_new_track_idx,tracks_layout.TrackIDCol)=(max_cell_id+1);
mtr_gui_struct.Tracks=tracks;
%increase the generation number of the daughter cells and all their
%proginy
offsetGenerationNumber(parent_id,1);

%end completeSplitTrack
end

function completeContinueTrack()
global mtr_gui_struct;

track_to_remove_ancestry=mtr_gui_struct.CurrentAncestryRecord;
track_to_continue_ancestry=mtr_gui_struct.TrackToContinueAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
track_to_remove_start_time=track_to_remove_ancestry(ancestry_layout.StartTimeCol);
track_to_continue_stop_time=track_to_continue_ancestry(ancestry_layout.StopTimeCol);
if (track_to_continue_stop_time~=(track_to_remove_start_time-mtr_gui_struct.TimeFrame))
    mtr_gui_struct.TrackToContinueID=[];
    mtr_gui_struct.TrackToContinueRecord=[];
    mtr_gui_struct.TrackToContinueAncestry=[];
    mtr_gui_struct.ContinueTrack=false;
    warndlg('You cannot continue the track using this track.  The overlap between the tracks is incorrect!');
    return;
end

tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
track_to_continue_id=mtr_gui_struct.TrackToContinueID;
track_to_remove_id=mtr_gui_struct.SelectedCellID;
track_to_remove_idx=track_to_remove_id==tracks(:,tracks_layout.TrackIDCol);
%continue the track
tracks(track_to_remove_idx,tracks_layout.TrackIDCol)=track_to_continue_id;
mtr_gui_struct.Tracks=tracks;
track_to_continue_ancestry(ancestry_layout.StopTimeCol)=track_to_remove_ancestry(ancestry_layout.StopTimeCol);
mtr_gui_struct.CurrentAncestryRecord=track_to_continue_ancestry;
cells_ancestries=mtr_gui_struct.CellsAncestry;
cells_ancestries(cells_ancestries(:,ancestry_layout.TrackIDCol)==track_to_remove_id,:)=[];
cells_ancestries(cells_ancestries(:,ancestry_layout.TrackIDCol)...
    ==track_to_continue_id,:)=track_to_continue_ancestry;
mtr_gui_struct.CellsAncestry=cells_ancestries;
mtr_gui_struct.TrackToContinueID=[];
mtr_gui_struct.TrackToContinueRecord=[];
mtr_gui_struct.TrackToContinueAncestry=[];
mtr_gui_struct.ContinueTrack=false;
mtr_gui_struct.SelectedCellStart=(track_to_continue_ancestry(ancestry_layout.StartTimeCol)...
    ./mtr_gui_struct.TimeFrame)+1;
mtr_gui_struct.SelectedCellID=track_to_continue_id;
updateCellStatus();

%end completeContinueTrack
end

function cell_id=getCellIDFromLabelID()
global mtr_gui_struct;

cur_cell_blob=mtr_gui_struct.CurCellBlob;
[cur_cell_1 cur_cell_2]=find(cur_cell_blob);
cur_cell_centroid=sum([cur_cell_1 cur_cell_2])./sum(cur_cell_blob(:));
tracks_layout=mtr_gui_struct.TracksLayout;
tracks=mtr_gui_struct.Tracks;
cur_time=(mtr_gui_struct.CurFrame-1)*mtr_gui_struct.TimeFrame;
cur_tracks_idx=(tracks(:,tracks_layout.TimeCol)==cur_time);
cur_tracks=tracks(cur_tracks_idx,:);
cur_centroids=tracks(cur_tracks_idx,tracks_layout.Centroid1Col:tracks_layout.Centroid2Col);
cur_dist=hypot(cur_cell_centroid(1)-cur_centroids(:,1),cur_cell_centroid(2)-cur_centroids(:,2));
[dummy cell_idx]=min(cur_dist);
cur_track_record=cur_tracks(cell_idx,:);
mtr_gui_struct.CurrentTrackRecord=cur_track_record;
cell_id=cur_track_record(tracks_layout.TrackIDCol);

%end getCellIDFromLabelID
end