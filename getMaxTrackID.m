function output_arg=getMaxTrackID(input_arg)

output_arg.MaxTrackID=max(input_arg.Tracks.Value(:,input_arg.TrackIDCol.Value));

%end getMaxTrackID
end