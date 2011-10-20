function output_args=makeAncestryForFirstFrameCells(input_args)
% Usage
% This module is used to create ancestry records for cells present in the first frame of a time-lapse movie.  These cells are generation zero.
% Input Structure Members
% TimeCol – The index of the time column in the tracks matrix.
% TrackIDCol – The index of the track ID column in the tracks matrix.
% TrackIDs – The IDs of all the tracks.
% Tracks – The matrix containing all the tracks.
% Output Structure Members
% CellsAncestry – The ancestry records for the cells in the first frame.
% FirstFrameIDs – IDs of cells in the first frame.
% UntestedIDs – IDs of cells in the movie that were not present in the first frame.

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
