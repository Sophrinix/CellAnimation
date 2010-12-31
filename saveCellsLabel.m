function output_args=saveCellsLabel(input_args)
%module to save the cell label matrix
cells_lbl=input_args.CellsLabel.Value;
save([input_args.FileRoot.Value num2str(input_args.CurFrame.Value,input_args.NumberFormat.Value)],'cells_lbl');
output_args.CellsLabel=cells_lbl;

%end saveCellsLabel
end