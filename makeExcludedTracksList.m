function output_args=makeExcludedTracksList(input_args)
%Usage
%This module wraps its input, a list of cell IDs, in a MATLAB cell array.
%
%Input Structure Members
%UnassignedCellsIDs – The list of cell IDs.
%
%Output Structure Members
%ExcludedTracks – The MATLAB cell array.
%
%Example
%
%make_excluded_tracks_list_function.InstanceName='MakeExcludedTracksList';
%make_excluded_tracks_list_function.FunctionHandle=@makeExcludedTracksList;
%make_excluded_tracks_list_function.FunctionArgs.UnassignedCellsIDs.FunctionIn
%stance='MakeUnassignedCellsList';
%make_excluded_tracks_list_function.FunctionArgs.UnassignedCellsIDs.OutputArg=
%'UnassignedCellsIDs';
%else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_la
%bel_functions,make_excluded_tracks_list_function);
%
%…
%
%assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.FunctionInstance='Mak
%eExcludedTracksList';
%assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.OutputArg='ExcludedTr
%acks';

output_args.ExcludedTracks=cell(size(input_args.UnassignedCellsIDs.Value,1),1);

%end makeExcludedTracksList
end
