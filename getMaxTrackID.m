function output_arg=getMaxTrackID(input_arg)
%Usage
%This module is used to return the current maximum track ID from a track matrix.
%
%Input Structure Members
%TrackIDCol – Index of the track ID column in the tracks matrix.
%Tracks – Matrix containing the set of tracks.
%
%Output Structure Members
%MaxTrackID – The maximum track ID.
%
%Example
%
%get_max_track_id_function.InstanceName='GetMaxTrackID';
%get_max_track_id_function.FunctionHandle=@getMaxTrackID;
%get_max_track_id_function.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPrev
%iousCellsLabel';
%get_max_track_id_function.FunctionArgs.Tracks.OutputArg='Tracks';
%get_max_track_id_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackID
%Col;
%
%else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_la
%bel_functions,get_max_track_id_function);
%
%…
%
%assign_cells_to_tracks_loop.FunctionArgs.MaxTrackID.FunctionInstance='GetMaxT
%rackID';
%assign_cells_to_tracks_loop.FunctionArgs.MaxTrackID.OutputArg='MaxTrackID';

output_arg.MaxTrackID=max(input_arg.Tracks.Value(:,input_arg.TrackIDCol.Value));

%end getMaxTrackID
end
