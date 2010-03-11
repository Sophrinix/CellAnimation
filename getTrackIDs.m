function output_args=getTrackIDs(input_args)

output_args.TrackIDs=unique(input_args.Tracks.Value(:,input_args.TrackIDCol.Value));

%end getTrackIDs
end