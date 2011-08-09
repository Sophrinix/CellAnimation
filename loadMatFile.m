function output_args=loadMatFile(input_args)
%Usage
%This module is used to load all the variables in a MATLAB .mat file.
%
%Input Structure Members
%MatFileName – The name of the .mat file.
%
%Output Structure Members
%Each of the variable names and values found in the .mat file will be replicated in the output
%structure.
%
%Example
%
%load_cells_label_function.InstanceName='LoadCellsLabel';
%load_cells_label_function.FunctionHandle=@loadMatFile;
%load_cells_label_function.FunctionArgs.MatFileName.FunctionInstance='MakeMatN
%amesInOverlayLoop';
%load_cells_label_function.FunctionArgs.MatFileName.OutputArg='FileName';
%image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,
%
%load_cells_label_function);
%
%…
%
%display_ancestry_function.FunctionArgs.CellsLabel.FunctionInstance='LoadCells
%Label';
%display_ancestry_function.FunctionArgs.CellsLabel.OutputArg='cells_lbl';

mat_file_name=input_args.MatFileName.Value;
vars_info = whos('-file', mat_file_name); 
load_struct=load(mat_file_name);
for i=1:length(vars_info)
    var_name=vars_info(i).name;
    output_args.(var_name)=load_struct.(var_name);
end

end
