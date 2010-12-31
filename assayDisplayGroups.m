function []=pipelineDisplayGroups(well_folder)

ds='\';
root_folder='c:\darren';
track_struct.StartFrame=1;
track_struct.FrameCount=72;
track_struct.FrameStep=1;
track_struct.TimeFrame=15; %minutes
track_struct.ImageFileName='DsRed - Confocal - n';
track_struct.NumberFormat='%06d';
track_struct.ImgExt='.tif';
track_struct.ImageFileBase=[well_folder ds track_struct.ImageFileName];
name_idx=find(well_folder==ds,2,'last');
%generate a unique well name
well_name=well_folder((name_idx(1)+1):end);
well_name(name_idx(2)-name_idx(1))=[];
well_name(well_name==' ')=[];
track_struct.OutputFolder=[root_folder ds 'output' ds well_name];
track_dir=[track_struct.OutputFolder ds 'track'];
prol_dir=[track_struct.OutputFolder ds 'proliferation'];
track_struct.SegFileRoot=[track_dir ds 'grayscale'];
track_struct.MatchingGroupsDir=[track_struct.OutputFolder ds 'groups'];
track_struct.TracksFile=[prol_dir ds 'tracks.mat'];
mkdir(track_struct.MatchingGroupsDir);

%tracks grid layout
tracks_layout.TrackIDCol=1;
tracks_layout.TimeCol=2;
tracks_layout.Centroid1Col=3;
tracks_layout.Centroid2Col=4;
%always start shape params after centroid2col
tracks_layout.AreaCol=5; %area 3 gp
tracks_layout.EccCol=6; %eccentricity 4 bp
tracks_layout.MalCol=7; %major axis length 5 gp
tracks_layout.MilCol=8; %minor axis length 6 gp
tracks_layout.OriCol=9; %orientation 7
tracks_layout.PerCol=10; %perimeter 8
tracks_layout.SolCol=11; %solidity 9 bp
tracks_layout.BlobIDCol=12; %pixel blob id - used to get rid of oversegmentation
tracks_layout.MatchGroupIDCol=13; %matching group id - to determine which parameters to use when matching

global functions_list;
functions_list=[];
%program logic starts here

load_tracks_function.InstanceName='LoadTracks';
load_tracks_function.FunctionHandle=@loadMatFile;
load_tracks_function.FunctionArgs.MatFileName.Value=track_struct.TracksFile;
functions_list=addToFunctionChain(functions_list,load_tracks_function);

load_colormap_function.InstanceName='LoadColormap';
load_colormap_function.FunctionHandle=@loadMatFile;
load_colormap_function.FunctionArgs.MatFileName.Value='colormap_lines';
functions_list=addToFunctionChain(functions_list,load_colormap_function);


image_overlay_loop.InstanceName='ImageOverlayLoop';
image_overlay_loop.FunctionHandle=@forLoop;
image_overlay_loop.FunctionArgs.StartLoop.Value=track_struct.StartFrame;
image_overlay_loop.FunctionArgs.EndLoop.Value=(track_struct.StartFrame+track_struct.FrameCount-1)*track_struct.FrameStep;
image_overlay_loop.FunctionArgs.IncrementLoop.Value=track_struct.FrameStep;
image_overlay_loop.FunctionArgs.Tracks.FunctionInstance='LoadTracks';
image_overlay_loop.FunctionArgs.Tracks.OutputArg='tracks';
image_overlay_loop.FunctionArgs.ColorMap.FunctionInstance='LoadColormap';
image_overlay_loop.FunctionArgs.ColorMap.OutputArg='cmap';
image_overlay_loop.FunctionArgs.GroupIDs.Value=[1:35];
image_overlay_loop.LoopFunctions=[];

make_file_name_function.InstanceName='MakeImageNamesInOverlayLoop';
make_file_name_function.FunctionHandle=@makeImgFileName;
make_file_name_function.FunctionArgs.FileBase.Value=track_struct.ImageFileBase;
make_file_name_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
make_file_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_file_name_function.FunctionArgs.NumberFmt.Value=track_struct.NumberFormat;
make_file_name_function.FunctionArgs.FileExt.Value=track_struct.ImgExt;
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,make_file_name_function);

read_image_function.InstanceName='ReadImagesInOverlayLoop';
read_image_function.FunctionHandle=@readImage;
read_image_function.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInOverlayLoop';
read_image_function.FunctionArgs.ImageName.OutputArg='FileName';
read_image_function.FunctionArgs.ImageChannel.Value='';
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,read_image_function);

get_cur_tracks_function.InstanceName='GetCurrentTracks';
get_cur_tracks_function.FunctionHandle=@getCurrentTracks;
get_cur_tracks_function.FunctionArgs.Tracks.FunctionInstance='ImageOverlayLoop';
get_cur_tracks_function.FunctionArgs.Tracks.InputArg='Tracks';
get_cur_tracks_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
get_cur_tracks_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
get_cur_tracks_function.FunctionArgs.OffsetFrame.Value=0;
get_cur_tracks_function.FunctionArgs.TimeFrame.Value=track_struct.TimeFrame;
get_cur_tracks_function.FunctionArgs.TimeCol.Value=tracks_layout.TimeCol;
get_cur_tracks_function.FunctionArgs.TrackIDCol.Value=tracks_layout.TrackIDCol;
get_cur_tracks_function.FunctionArgs.MaxMissingFrames.Value=0;
get_cur_tracks_function.FunctionArgs.FrameStep.Value=track_struct.FrameStep;
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,get_cur_tracks_function);

make_mat_name_function.InstanceName='MakeMatNamesInOverlayLoop';
make_mat_name_function.FunctionHandle=@makeImgFileName;
make_mat_name_function.FunctionArgs.FileBase.Value=track_struct.SegFileRoot;
make_mat_name_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
make_mat_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_mat_name_function.FunctionArgs.NumberFmt.Value=track_struct.NumberFormat;
make_mat_name_function.FunctionArgs.FileExt.Value='.mat';
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,make_mat_name_function);

load_cells_label_function.InstanceName='LoadCellsLabel';
load_cells_label_function.FunctionHandle=@loadMatFile;
load_cells_label_function.FunctionArgs.MatFileName.FunctionInstance='MakeMatNamesInOverlayLoop';
load_cells_label_function.FunctionArgs.MatFileName.OutputArg='FileName';
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,load_cells_label_function);

display_overlaying_frame_function.InstanceName='DisplayOverlayingFrame';
display_overlaying_frame_function.FunctionHandle=@displayVariable;
display_overlaying_frame_function.FunctionArgs.Variable.FunctionInstance='ImageOverlayLoop';
display_overlaying_frame_function.FunctionArgs.Variable.OutputArg='LoopCounter';
display_overlaying_frame_function.FunctionArgs.VariableName.Value='Overlaying Frame';
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,display_overlaying_frame_function);

display_groups_function.InstanceName='DisplayMatchingGroups';
display_groups_function.FunctionHandle=@displayMatchingGroupsData;
display_groups_function.FunctionArgs.Image.FunctionInstance='ReadImagesInOverlayLoop';
display_groups_function.FunctionArgs.Image.OutputArg='Image';
display_groups_function.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks';
display_groups_function.FunctionArgs.CurrentTracks.OutputArg='Tracks';
display_groups_function.FunctionArgs.CellsLabel.FunctionInstance='LoadCellsLabel';
display_groups_function.FunctionArgs.CellsLabel.OutputArg='cells_lbl';
display_groups_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
display_groups_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
display_groups_function.FunctionArgs.ColorMap.FunctionInstance='ImageOverlayLoop';
display_groups_function.FunctionArgs.ColorMap.InputArg='ColorMap';
display_groups_function.FunctionArgs.GroupIDs.FunctionInstance='ImageOverlayLoop';
display_groups_function.FunctionArgs.GroupIDs.InputArg='GroupIDs';
display_groups_function.FunctionArgs.NumberFormat.Value=track_struct.NumberFormat;
display_groups_function.FunctionArgs.TracksLayout.Value=tracks_layout;
display_groups_function.FunctionArgs.MatchingGroupsDir.Value=track_struct.MatchingGroupsDir;
display_groups_function.FunctionArgs.ImageFileName.Value=track_struct.ImageFileName;
display_groups_function.FunctionArgs.DS.Value=ds;
display_groups_function.FunctionArgs.PrintGroupID.Value=true;
image_overlay_loop.LoopFunctions=addToFunctionChain(image_overlay_loop.LoopFunctions,display_groups_function);

functions_list=addToFunctionChain(functions_list,image_overlay_loop);

%determine dependencies and run the chain
global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end pipelineDisplayGroups
end