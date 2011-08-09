function output_args=loadCellsLabel(input_args)
%Usage
%This module is used to load cells/nuclei labels. It looks for a variable named cells_lbl in the .mat
%data file.
%
%Input Structure Members
%MatFileName – The name of the data file.
%
%Output Structure Members
%LabelMatrix – The label matrix loaded from the file.
%
%Example
%
%load_cells_label_function.InstanceName='LoadCellsLabel';
%load_cells_label_function.FunctionHandle=@loadMatFile;
%load_cells_label_function.FunctionArgs.MatFileName.FunctionInstance='MakeMatN
%amesInOverlayLoop';
%load_cells_label_function.FunctionArgs.MatFileName.OutputArg='FileName';
%image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,
%load_cells_label_function);
%
%…
%
%display_ancestry_function.FunctionArgs.CellsLabel.FunctionInstance='LoadCells
%Label';
%display_ancestry_function.FunctionArgs.CellsLabel.OutputArg='cells_lbl';

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
