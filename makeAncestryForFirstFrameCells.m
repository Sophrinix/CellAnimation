function output_args=makeAncestryForFirstFrameCells(input_args)
%create ancestry records cells that are present in the first frame. 
%they are generation zero and have no parents

timeCol=input_args.TimeCol.Value;
trackIDCol=input_args.TrackIDCol.Value;
tracks=input_args.Tracks.Value;
track_ids=input_args.TrackIDs.Value;

first_frame_ids=tracks(tracks(:,timeCol)==0,trackIDCol);
first_frame_ids_len=length(first_frame_ids);
stop_times=zeros(first_frame_ids_len,1);
for i=1:first_frame_ids_len
    track_times=tracks(tracks(:,trackIDCol)==first_frame_ids(i),timeCol);
    stop_times(i)=track_times(end);
end
output_args.CellsAncestry=[first_frame_ids zeros(first_frame_ids_len,1) ones(first_frame_ids_len,1)...
    zeros(first_frame_ids_len,1) stop_times];
output_args.UntestedIDs=setdiff(track_ids,first_frame_ids);
output_args.FirstFrameIDs=first_frame_ids;

%end makeAncestryForFirstFrameCells
end