function output_args=saveTracks(input_args)
%Usage
%This module is used to save the tracks matrix.
%
%Input Structure Members
%
%Tracks – Matrix containing the tracks to be saved.
%TracksFileName – The desired file name for the saved tracks data.
%
%Output Structure Members
%None.
%
%Example
%
%save_tracks_function.InstanceName='SaveTracks';
%save_tracks_function.FunctionHandle=@saveTracks;
%save_tracks_function.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
%save_tracks_function.FunctionArgs.Tracks.OutputArg='Tracks';
%save_tracks_function.FunctionArgs.TracksFileName.Value=TrackStruct.TracksFile
%;
%functions_list=addToFunctionChain(functions_list,save_tracks_function);

tracks=input_args.Tracks.Value;
file_name=input_args.TracksFileName.Value;
save_dir_idx=find(file_name=='/',1,'last');
save_dir=file_name(1:(save_dir_idx-1));
if ~isdir(save_dir)
    mkdir(save_dir);
end
save(file_name,'tracks');
output_args=[];

%end saveTracks
end
