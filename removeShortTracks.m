function output_args=removeShortTracks(input_args)
%Usage
%This module is used to erase tracks with a lifespan shorter than a specified period of time.
%
%Input Structure Members
%AncestryLayout – Matrix describing the order of the columns in the ancestry matrix.
%Tracks – The tracks matrix to be processed.
%CellsAncestry – Matrix containing the ancestry records for the cells in the time-lapse movie.
%TracksLayout – Matrix describing the order of the columns in the tracks matrix.
%MinLifespan – Tracks with a lifespan shorter than this value will be erased.
%
%Output Structure Members
%Tracks – The filtered tracks matrix.
%
%Example
%
%remove_short_tracks_function.InstanceName='RemoveShortTracks';
%remove_short_tracks_function.FunctionHandle=@removeShortTracks;
%remove_short_tracks_function.FunctionArgs.Tracks.FunctionInstance='SplitTrack
%s';
%remove_short_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
%remove_short_tracks_function.FunctionArgs.CellsAncestry.FunctionInstance='Spl
%itTracks';
%remove_short_tracks_function.FunctionArgs.CellsAncestry.OutputArg='CellsAnces
%try';
%remove_short_tracks_function.FunctionArgs.TracksLayout.Value=tracks_layout;
%remove_short_tracks_function.FunctionArgs.AncestryLayout.Value=ancestry_layou
%t;
%remove_short_tracks_function.FunctionArgs.MinLifespan.Value=30; %minutes
%functions_list=addToFunctionChain(functions_list,remove_short_tracks_function
%);
%
%…
%
%save_updated_tracks_function.FunctionArgs.Tracks.FunctionInstance='RemoveShor
%tTracks';
%save_updated_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';

tracks=input_args.Tracks.Value;
ancestry=input_args.CellsAncestry.Value;
ancestry_layout=input_args.AncestryLayout.Value;
tracks_layout=input_args.TracksLayout.Value;
start_time_col=ancestry_layout.StartTimeCol;
stop_time_col=ancestry_layout.StopTimeCol;
parent_id_col=ancestry_layout.ParentIDCol;
cells_life_span=ancestry(:,stop_time_col)-ancestry(:,start_time_col);
max_time=max(ancestry(:,stop_time_col));
min_life_span=input_args.MinLifespan.Value;
invalid_tracks_idx=cells_life_span<min_life_span;
tracks_starting_late_idx=ancestry(:,start_time_col)>=max_time-min_life_span;
%do not remove the tracks that start in the end frames
invalid_tracks_idx(tracks_starting_late_idx)=false;
tracks_that_are_parents_idx=ismember(ancestry(:,ancestry_layout.TrackIDCol),ancestry(:,parent_id_col));
%do not remove short tracks that are parents
invalid_tracks_idx(tracks_that_are_parents_idx)=false;
invalid_track_ids=ancestry(invalid_tracks_idx,ancestry_layout.TrackIDCol);
output_args.CellsAncestry=ancestry(~invalid_tracks_idx,:);
invalid_tracks_idx=ismember(tracks(:,tracks_layout.TrackIDCol),invalid_track_ids);
output_args.Tracks=tracks(~invalid_tracks_idx,:);

%end removeShortTracks
end
