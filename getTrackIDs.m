function output_args=getTrackIDs(input_args)
% Usage
% This module is used to retrieve the list of track IDs from the track matrix.
% Input Structure Members
% TrackIDCol – Index of the track ID column in the tracks matrix.
% Tracks – Matrix containing the set of tracks from which IDs will be extracted.
% Output Structure Members
% TrackIDs – The IDs extracted from the tracks matrix.

output_args.TrackIDs=unique(input_args.Tracks.Value(:,input_args.TrackIDCol.Value));

%end getTrackIDs
end
