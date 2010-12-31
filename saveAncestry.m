function output_args=saveAncestry(input_args)
%module to save the ancestry matrix
cells_ancestry=input_args.CellsAncestry.Value;
save(input_args.AncestryFileName.Value,'cells_ancestry');
output_args=[];

%end saveTracks
end