function output_args=loadCellsLabel(input_args)
%module to load cells/nuclei labels used by many assays

mat_file_name=input_args.MatFileName.Value;
try
    load_struct=load(mat_file_name);
catch
    warning(['Failed to load ' mat_file_name '! loadCellsLabel will return an empty image.']);
    output_args.LabelMatrix=[];
    return;
end
output_args.LabelMatrix=load_struct.cells_lbl;

%end loadCellsLabel
end