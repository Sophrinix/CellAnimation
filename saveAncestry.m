function output_args=saveAncestry(input_args)
%Usage
%This module is used to save the cells ancestry matrix. The matrix is saved with the variable
%name cells_ancestry.
%
%Input Structure Members
%AncestryFileName – The file name to which the cell ancestry matrix should be saved.
%CellsAncestry – The matrix containing the cells ancestry records.
%
%Output Structure Members
%None
%
%Example
%
%save_ancestry_function.InstanceName='SaveAncestry';
%save_ancestry_function.FunctionHandle=@saveAncestry;
%save_ancestry_function.FunctionArgs.CellsAncestry.FunctionInstance='RemoveSho
%rtTracks';
%save_ancestry_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
%save_ancestry_function.FunctionArgs.AncestryFileName.Value=[TrackStruct.ProlD
%ir ds 'ancestry.mat'];
%functions_list=addToFunctionChain(functions_list,save_ancestry_function);

cells_ancestry=input_args.CellsAncestry.Value;
save(input_args.AncestryFileName.Value,'cells_ancestry');
output_args=[];

%end saveTracks
end
