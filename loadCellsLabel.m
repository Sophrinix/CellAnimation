function output_args=loadCellsLabel(input_args)

mat_file_name=input_args.MatFileName.Value;
try
    load_struct=load(mat_file_name);
catch
   output_args.cells_lbl=[];
   return;
end
output_args.LabelMatrix=load_struct.cells_lbl;

%end loadCellsLabel
end