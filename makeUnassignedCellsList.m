function output_args=makeUnassignedCellsList(input_args)
%Usage
%This module is used to create a list of IDs for each cell centroid in a list.
%
%Input Structure Members
%CellsCentroids – List of cell centroids.
%
%Output Structure Members
%UnassignedCellsIDs – List of IDs.
%
%Example
%
%make_unassigned_cells_list_function.InstanceName='MakeUnassignedCellsList';
%make_unassigned_cells_list_function.FunctionHandle=@makeUnassignedCellsList;
%make_unassigned_cells_list_function.FunctionArgs.CellsCentroids.FunctionInsta
%nce='GetShapeParameters';
%make_unassigned_cells_list_function.FunctionArgs.CellsCentroids.OutputArg='Ce
%ntroids';
%else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_la
%bel_functions,make_unassigned_cells_list_function);
%
%…
%
%make_excluded_tracks_list_function.FunctionArgs.UnassignedCellsIDs.FunctionIn
%stance='MakeUnassignedCellsList';
%make_excluded_tracks_list_function.FunctionArgs.UnassignedCellsIDs.OutputArg=
%'UnassignedCellsIDs';

output_args.UnassignedCellsIDs=[1:size(input_args.CellsCentroids.Value,1)]';

%end makeUnassignedCellsList 
end
