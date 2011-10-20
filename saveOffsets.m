function output_args=saveOffsets(input_args)
%Usage
%This module is used to save the xy offset data to file
% Input Structure Members
% FileName – The path to the location where the offset data should be saved.
% XYOffsets – The matrix containing the offsets data.
% Output Structure Members
% None


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
