function output_args=saveAncestry(input_args)

cells_ancestry=input_args.CellsAncestry.Value;
save(input_args.AncestryFileName.Value,'cells_ancestry');
output_args=[];

%end saveTracks
end