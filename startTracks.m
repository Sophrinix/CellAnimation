function output_args=startTracks(input_args)
%Usage
%This module is used to start a tracks matrix.
%
%Input Structure Members
%CellsLabel – The label matrix identifying the objects in the first frame of the time-lapse.
%CurFrame – The index value of the current frame.
%ShapeParameters – The shape parameters for the objects in the first frame (Area, Eccentricity,
%etc.).
%TimeFrame – The time interval between consecutive frames in the time-lapse.
%
%Output Structure Members
%Tracks – The new tracks matrix.
%
%Example
%
%start_tracks_function.InstanceName='StartTracks';
%start_tracks_function.FunctionHandle=@startTracks;
%start_tracks_function.FunctionArgs.CellsLabel.FunctionInstance='IfIsEmptyPrev
%iousCellsLabel';
%start_tracks_function.FunctionArgs.CellsLabel.InputArg='CellsLabel'; %only
%works for subfunctions
%start_tracks_function.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPrevio
%usCellsLabel';
%start_tracks_function.FunctionArgs.CurFrame.InputArg='CurFrame'; %only works
%for subfunctions
%start_tracks_function.FunctionArgs.TimeFrame.Value=TrackStruct.TimeFrame;
%start_tracks_function.FunctionArgs.ShapeParameters.FunctionInstance='GetShape
%Parameters';
%start_tracks_function.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters
%';
%if_is_empty_cells_label_functions=addToFunctionChain(if_is_empty_cells_label_
%functions,start_tracks_function);
%
%…
%
%if_is_empty_cells_label_function.KeepValues.Tracks.FunctionInstance='StartTra
%cks';
%if_is_empty_cells_label_function.KeepValues.Tracks.OutputArg='Tracks';

cells_props=regionprops(input_args.CellsLabel.Value,'Centroid');
cells_centroids=[cells_props.Centroid]';
cells_centroids_2=cells_centroids(1:2:length(cells_centroids));
cells_centroids_1=cells_centroids(2:2:length(cells_centroids));
cur_time=repmat((input_args.CurFrame.Value-1)*input_args.TimeFrame.Value,size(cells_centroids_1,1),1);
track_ids=[1:size(cells_centroids_1,1)]';
output_args.Tracks=[track_ids cur_time cells_centroids_1 cells_centroids_2 input_args.ShapeParameters.Value];
output_args.PotentialCellParams=[];
output_args.CellsLabel=input_args.CellsLabel.Value;
output_args.MatchingGroups=[];

%end startTracks
end
