function output_arg=getMaxTrackID(input_arg)
%module to return the current maximun track ID
output_arg.MaxTrackID=max(input_arg.Tracks.Value(:,input_arg.TrackIDCol.Value));

%end getMaxTrackID
end