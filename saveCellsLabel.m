function output_args=saveCellsLabel(input_args)
%Usage
%This module is used to save a MATLAB label matrix containing cell objects.
%
%Input Structure Members
%CellsLabel – The label matrix containing cell objects.
%CurFrame – The index of the frame to which the label matrix corresponds.
%FileRoot – String containing the root of the file name to be used when saving the label matrix.
%NumberFormat – String indicating the number format to be used when formatting the current
%frame number to be concatenated to the file root string. See the MATLAB sprintf help file for
%example number format strings.
%
%Output Structure Members
%CellsLabel – The label matrix containing cell objects.
%
%Example
%
%save_cells_label_function.InstanceName='SaveCellsLabel';
%save_cells_label_function.FunctionHandle=@saveCellsLabel;
%save_cells_label_function.FunctionArgs.CellsLabel.FunctionInstance='ResizeCyt
%oLabel';
%save_cells_label_function.FunctionArgs.CellsLabel.OutputArg='Image';
%save_cells_label_function.FunctionArgs.CurFrame.FunctionInstance='Segmentatio
%nLoop';
%save_cells_label_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
%save_cells_label_function.FunctionArgs.FileRoot.Value=TrackStruct.SegFileRoot
%;
%save_cells_label_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberF
%ormat;
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,save_c
%ells_label_function);

cells_lbl=input_args.CellsLabel.Value;
save([input_args.FileRoot.Value num2str(input_args.CurFrame.Value,input_args.NumberFormat.Value)],'cells_lbl');
output_args.CellsLabel=cells_lbl;

%end saveCellsLabel
end
