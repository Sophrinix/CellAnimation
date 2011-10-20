function output_args=saveAncestry(input_args)
% Usage
% This module is used to save the cells ancestry matrix. The matrix is saved with the variable name cells_ancestry.
% Input Structure Members
% AncestryFileName – The file name to which the cell ancestry matrix should be saved.
% CellsAncestry – The matrix containing the cells ancestry records.
% Output Structure Members
% None

cells_ancestry=input_args.CellsAncestry.Value;
file_name=input_args.AncestryFileName.Value;
save_dir_idx=find(file_name=='/',1,'last');
save_dir=file_name(1:(save_dir_idx-1));
if ~isdir(save_dir)
    mkdir(save_dir);
end
save(file_name,'cells_ancestry');
output_args=[];

%end saveTracks
end
