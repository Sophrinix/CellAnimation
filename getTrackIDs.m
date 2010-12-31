function output_args=getTrackIDs(input_args)
%module to return the unique track IDs from the list of tracks
output_args.TrackIDs=unique(input_args.Tracks.Value(:,input_args.TrackIDCol.Value));

%end getTrackIDs
end