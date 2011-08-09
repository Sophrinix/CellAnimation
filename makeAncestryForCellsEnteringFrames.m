function output_args=makeAncestryForCellsEnteringFrames(input_args)
%Usage
%This module is used to add ancestry records for cells entering the field of view after the first
%frame (not the result of a mitotic event in the field of view).
%
%Input Structure Members
%CellsAncestry – Current cell ancestry records.
%FirstFrameIDs – The IDs of tracks starting in the first frame.
%SplitCells – The IDs of tracks that are the result of mitosis.
%TimeCol – The index of the time column in the tracks matrix.
%TrackIDCol – The index of the track ID column in the tracks matrix.
%TrackIDs – The IDs of all the tracks.
%Tracks – The matrix containing all the tracks.
%
%Output Structure Members
%CellsAncestry – The current cell ancestry record with ancestry of cells entering the field of view
%after the first frame appended to the end.
%
%Example
%
%make_ancestry_for_cells_entering_frames_function.InstanceName='MakeAncestryFo
%rCellsEnteringFrames';
%make_ancestry_for_cells_entering_frames_function.FunctionHandle=@makeAncestry
%ForCellsEnteringFrames;
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.SplitCells.Func
%tionInstance='DetectMitoticEvents';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.SplitCells.Outp
%utArg='SplitCells';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.TrackIDs.Functi
%onInstance='GetTrackIDsAfterMerge';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.TrackIDs.Output
%Arg='TrackIDs';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.FirstFrameIDs.F
%unctionInstance='MakeAncestryForFirstFrameCells';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.FirstFrameIDs.O
%utputArg='FirstFrameIDs';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.CellsAncestry.F
%unctionInstance='MakeAncestryForFirstFrameCells';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.CellsAncestry.O
%utputArg='CellsAncestry';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.Tracks.Function
%Instance='MergeTracks';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.Tracks.OutputAr
%g='Tracks';
%
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.TimeCol.Value=t
%racks_layout.TimeCol;
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.TrackIDCol.Valu
%e=tracks_layout.TrackIDCol;
%functions_list=addToFunctionChain(functions_list,make_ancestry_for_cells_ente
%ring_frames_function);
%
%…
%
%split_tracks_function.FunctionArgs.CellsAncestry.FunctionInstance='MakeAncest
%ryForCellsEnteringFrames';
%split_tracks_function.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';

split_cells=input_args.SplitCells.Value;
track_ids=input_args.TrackIDs.Value;
first_frame_ids=input_args.FirstFrameIDs.Value;
trackIDCol=input_args.TrackIDCol.Value;
timeCol=input_args.TimeCol.Value;
tracks=input_args.Tracks.Value;
cells_ancestry=input_args.CellsAncestry.Value;

if (isempty(split_cells))
    cells_entering_frame_ids=setdiff(track_ids,first_frame_ids);
else
    cells_entering_frame_ids=setdiff(track_ids,[first_frame_ids; split_cells(:,2)]);
end
cells_entering_frame_len=length(cells_entering_frame_ids);
start_times=zeros(cells_entering_frame_len,1);
stop_times=zeros(cells_entering_frame_len,1);
for i=1:cells_entering_frame_len
    track_times=tracks(tracks(:,trackIDCol)==cells_entering_frame_ids(i),timeCol);
    start_times(i)=track_times(1);
    stop_times(i)=track_times(end);
end
output_args.CellsAncestry=[cells_ancestry; [cells_entering_frame_ids zeros(cells_entering_frame_len,1)... 
    ones(cells_entering_frame_len,1) start_times stop_times]];

%end makeAncestryForCellsEnteringFrames
end
