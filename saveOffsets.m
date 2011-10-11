function output_args=saveOffsets(input_args)
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

xy_offsets=input_args.XYOffsets.Value;
file_name=input_args.FileName.Value;
save_dir_idx=find(file_name=='/',1,'last');
save_dir=file_name(1:(save_dir_idx-1));
if ~isdir(save_dir)
    mkdir(save_dir);
end
save(file_name,'xy_offsets');
output_args=[];

%end saveTracks
end
