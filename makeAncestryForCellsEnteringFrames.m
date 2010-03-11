function output_args=makeAncestryForCellsEnteringFrames(input_args)
%add an ancestry record for cells entering the field of view after the
%first frame

split_cells=input_args.SplitCells.Value;
track_ids=input_args.TrackIDs.Value;
first_frame_ids=input_args.FirstFrameIDs.Value;
trackIDCol=input_args.TrackIDCol.Value;
timeCol=input_args.TimeCol.Value;
tracks=input_args.Tracks.Value;
cells_ancestry=input_args.CellsAncestry.Value;

if (isempty(split_cells))
    cells_entering_frame_ids=setdiff(track_ids,first_frame_ids);
else
    cells_entering_frame_ids=setdiff(track_ids,[first_frame_ids; split_cells(:,2)]);
end
cells_entering_frame_len=length(cells_entering_frame_ids);
start_times=zeros(cells_entering_frame_len,1);
stop_times=zeros(cells_entering_frame_len,1);
for i=1:cells_entering_frame_len
    track_times=tracks(tracks(:,trackIDCol)==cells_entering_frame_ids(i),timeCol);
    start_times(i)=track_times(1);
    stop_times(i)=track_times(end);
end
output_args.CellsAncestry=[cells_ancestry; [cells_entering_frame_ids zeros(cells_entering_frame_len,1)... 
    ones(cells_entering_frame_len,1) start_times stop_times]];

%end makeAncestryForCellsEnteringFrames
end