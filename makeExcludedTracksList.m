function output_args=makeExcludedTracksList(input_args)
%module to build an excluded tracks list
output_args.ExcludedTracks=cell(size(input_args.UnassignedCellsIDs.Value,1),1);

%end makeExcludedTracksList
end