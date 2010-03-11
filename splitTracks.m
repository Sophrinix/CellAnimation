function output_args=splitTracks(input_args)
%split tracks where we detected mitotic events and record cell ancestry

split_cells=input_args.SplitCells.Value;
tracks=input_args.Tracks.Value;
cells_ancestry=input_args.CellsAncestry.Value;
if isempty(split_cells)
    output_args.Tracks=tracks;
    output_args.CellsAncestry=cells_ancestry;
    return;
end
track_struct=input_args.TrackStruct.Value;

tracks_layout=track_struct.TracksLayout;
trackIDCol=tracks_layout.TrackIDCol;
timeCol=tracks_layout.TimeCol;
max_track_id=max(tracks(:,trackIDCol));
ancestry_layout=track_struct.AncestryLayout;
stopTimeCol=ancestry_layout.StopTimeCol;
generationCol=ancestry_layout.GenerationCol;
ancestryIDCol=ancestry_layout.TrackIDCol;
time_frame=track_struct.TimeFrame;

if (~isempty(split_cells))
    [dummy sort_idx]=sort(split_cells(:,3));
    split_cells=split_cells(sort_idx,:);
    split_cells_len=size(split_cells,1);
else
    split_cells_len=0;
end


for i=1:split_cells_len
    %get the parent track id
    parent_track_id=split_cells(i,1);
    %get the split time
    split_time=split_cells(i,3);    
    %check if parent track has already been split
    parent_ancestry_idx=(cells_ancestry(:,ancestryIDCol)==parent_track_id);
    parent_track_stop_time=cells_ancestry(parent_ancestry_idx,stopTimeCol);
    parent_track_generation=cells_ancestry(parent_ancestry_idx,generationCol);
    if (parent_track_stop_time>=split_time)
        %parent track needs to be split        
        new_track_id=max_track_id+1;
        max_track_id=new_track_id;        
        %set the new end time for the parent track
        new_stop_time=split_time-time_frame;
        cells_ancestry(parent_ancestry_idx,stopTimeCol)=new_stop_time;
        %update the parent track id after the split with the new track id
        new_track_idx=(tracks(:,trackIDCol)==parent_track_id)&(tracks(:,timeCol)>new_stop_time);
        tracks(new_track_idx,trackIDCol)=new_track_id;                
        %create an ancestry record for the new track        
        cells_ancestry=[cells_ancestry; ...
            [new_track_id parent_track_id parent_track_generation+1 split_time parent_track_stop_time]];
    end
    %add an ancestry record for the other daughter cell resulting from the split
    daughter_id=split_cells(i,2);
    daughter_stop_time=split_cells(i,4);
    cells_ancestry=[cells_ancestry; ...
        [daughter_id parent_track_id parent_track_generation+1 split_time daughter_stop_time]];
end

output_args.Tracks=tracks;
output_args.CellsAncestry=cells_ancestry;

%end splitTracks
end