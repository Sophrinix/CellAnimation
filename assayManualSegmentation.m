function []=assayManualSegmentation(well_folder)
%assay to review segmentation.
%This assay can only be used after cells have been segmented using another
%assay!

global functions_list;
functions_list=[];
TrackStruct=[];
TrackStruct.ImgExt='.tif';
ds='\'  %directory symbol
TrackStruct.DS=ds;
root_folder=well_folder;
TrackStruct.ImageFileName='Cell Tracker Red - Confocal - n';
%low hepsin expressing - not really wildtype
TrackStruct.ImageFileBase=[well_folder ds TrackStruct.ImageFileName];
%hepsin overexpressing
% TrackStruct.ImageFileBase=[well_folder ds 'llh_hep_lm7_t'];
TrackStruct.StartFrame=2;
TrackStruct.FrameCount=45;
TrackStruct.TimeFrame=8; %minutes
TrackStruct.FrameStep=1; %read every x frames
TrackStruct.NumberFormat='%06d';

name_idx=find(well_folder==ds,2,'last');
%generate a unique well name
well_name=well_folder((name_idx(1)+1):end);
well_name(name_idx(2)-name_idx(1))=[];
well_name(well_name==' ')=[];
TrackStruct.OutputFolder=[root_folder ds 'output' ds well_name];
track_dir=[TrackStruct.OutputFolder ds 'track'];
TrackStruct.TrackDir=track_dir;
mkdir(track_dir);
man_review_dir=[TrackStruct.OutputFolder ds 'manual_segmentation'];
TrackStruct.ManualDir=man_review_dir;
mkdir(man_review_dir);
TrackStruct.SegFileRoot=[track_dir ds 'grayscale'];
TrackStruct.ManFileRoot=[man_review_dir ds 'grayscale'];



TrackStruct.Channel='';
TrackStruct.MinCytoArea=30;
TrackStruct.MinNuclArea=30;
TrackStruct.bClearBorder=false;
TrackStruct.ClearBorderDist=0;
TrackStruct.WatershedMed=2;

display_trackstruct_function.InstanceName='DisplayTrackStruct';
display_trackstruct_function.FunctionHandle=@displayVariable;
display_trackstruct_function.FunctionArgs.Variable.Value=TrackStruct;
display_trackstruct_function.FunctionArgs.VariableName.Value='TrackStruct';
functions_list=addToFunctionChain(functions_list,display_trackstruct_function);
%threshold images
image_read_loop_functions=[];
image_read_loop.InstanceName='SegmentationLoop';
image_read_loop.FunctionHandle=@forLoop;
image_read_loop.FunctionArgs.StartLoop.Value=TrackStruct.StartFrame;
image_read_loop.FunctionArgs.EndLoop.Value=(TrackStruct.StartFrame+TrackStruct.FrameCount-1)*TrackStruct.FrameStep;
image_read_loop.FunctionArgs.IncrementLoop.Value=TrackStruct.FrameStep;
image_read_loop.FunctionArgs.MatchingGroups.Value=[]; %need to add another provider
image_read_loop.FunctionArgs.MatchingGroups.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.FunctionArgs.MatchingGroups.OutputArg='MatchingGroups';
image_read_loop.FunctionArgs.Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
image_read_loop.FunctionArgs.Tracks.OutputArg='Tracks';
image_read_loop.FunctionArgs.Tracks.Value=[];

display_curtrackframe_function.InstanceName='DisplayCurFrame';
display_curtrackframe_function.FunctionHandle=@displayVariable;
display_curtrackframe_function.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
display_curtrackframe_function.FunctionArgs.Variable.OutputArg='LoopCounter';
display_curtrackframe_function.FunctionArgs.VariableName.Value='Current Tracking Frame';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,display_curtrackframe_function);

make_file_name_function.InstanceName='MakeImageNamesInSegmentationLoop';
make_file_name_function.FunctionHandle=@makeImgFileName;
make_file_name_function.FunctionArgs.FileBase.Value=TrackStruct.ImageFileBase;
make_file_name_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
make_file_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_file_name_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_file_name_function.FunctionArgs.FileExt.Value=TrackStruct.ImgExt;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,make_file_name_function);

read_image_function.InstanceName='ReadImagesInSegmentationLoop';
read_image_function.FunctionHandle=@readImage;
read_image_function.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInSegmentationLoop';
read_image_function.FunctionArgs.ImageName.OutputArg='FileName';
read_image_function.FunctionArgs.ImageChannel.Value='';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,read_image_function);

enhance_contrast_function.InstanceName='EnhanceContrast';
enhance_contrast_function.FunctionHandle=@imadjust_Wrapper;
enhance_contrast_function.FunctionArgs.Image.FunctionInstance='ReadImagesInSegmentationLoop';
enhance_contrast_function.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,enhance_contrast_function);

make_cur_mat_name_function.InstanceName='MakeCurLabelName';
make_cur_mat_name_function.FunctionHandle=@makeImgFileName;
make_cur_mat_name_function.FunctionArgs.FileBase.Value=TrackStruct.SegFileRoot;
make_cur_mat_name_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
make_cur_mat_name_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
make_cur_mat_name_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_cur_mat_name_function.FunctionArgs.FileExt.Value='.mat';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,make_cur_mat_name_function);

load_current_label_function.InstanceName='LoadCurrentLabel';
load_current_label_function.FunctionHandle=@loadCellsLabel;
load_current_label_function.FunctionArgs.MatFileName.FunctionInstance='MakeCurLabelName';
load_current_label_function.FunctionArgs.MatFileName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,load_current_label_function);

get_previous_frame_nr_function.InstanceName='GetPreviousFrameNr';
get_previous_frame_nr_function.FunctionHandle=@addFunction;
get_previous_frame_nr_function.FunctionArgs.Number1.FunctionInstance='SegmentationLoop';
get_previous_frame_nr_function.FunctionArgs.Number1.OutputArg='LoopCounter';
get_previous_frame_nr_function.FunctionArgs.Number2.Value=-1;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,get_previous_frame_nr_function);

make_mat_name_function.InstanceName='MakePreviousLabelName';
make_mat_name_function.FunctionHandle=@makeImgFileName;
make_mat_name_function.FunctionArgs.FileBase.Value=TrackStruct.ManFileRoot;
make_mat_name_function.FunctionArgs.CurFrame.FunctionInstance='GetPreviousFrameNr';
make_mat_name_function.FunctionArgs.CurFrame.OutputArg='Sum';
make_mat_name_function.FunctionArgs.NumberFmt.Value=TrackStruct.NumberFormat;
make_mat_name_function.FunctionArgs.FileExt.Value='.mat';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,make_mat_name_function);

load_previous_label_function.InstanceName='LoadPreviousLabel';
load_previous_label_function.FunctionHandle=@loadCellsLabel;
load_previous_label_function.FunctionArgs.MatFileName.FunctionInstance='MakePreviousLabelName';
load_previous_label_function.FunctionArgs.MatFileName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,load_previous_label_function);

refine_segmentation_function.InstanceName='RefineSegmentation';
refine_segmentation_function.FunctionHandle=@refineSegmentation;
refine_segmentation_function.FunctionArgs.CurrentLabel.FunctionInstance='LoadCurrentLabel';
refine_segmentation_function.FunctionArgs.CurrentLabel.OutputArg='LabelMatrix';
refine_segmentation_function.FunctionArgs.PreviousLabel.FunctionInstance='LoadPreviousLabel';
refine_segmentation_function.FunctionArgs.PreviousLabel.OutputArg='LabelMatrix';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,refine_segmentation_function);

review_segmentation_function.InstanceName='ReviewSegmentation';
review_segmentation_function.FunctionHandle=@manualSegmentationReview;
review_segmentation_function.FunctionArgs.ObjectsLabel.FunctionInstance='RefineSegmentation';
review_segmentation_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.RawLabel.FunctionInstance='LoadCurrentLabel';
review_segmentation_function.FunctionArgs.RawLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.PreviousLabel.FunctionInstance='LoadPreviousLabel';
review_segmentation_function.FunctionArgs.PreviousLabel.OutputArg='LabelMatrix';
review_segmentation_function.FunctionArgs.Image.FunctionInstance='EnhanceContrast';
review_segmentation_function.FunctionArgs.Image.OutputArg='Image';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,review_segmentation_function);

save_cells_label_function.InstanceName='SaveReviewedLabel';
save_cells_label_function.FunctionHandle=@saveCellsLabel;
save_cells_label_function.FunctionArgs.CellsLabel.FunctionInstance='ReviewSegmentation';
save_cells_label_function.FunctionArgs.CellsLabel.OutputArg='LabelMatrix';
save_cells_label_function.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
save_cells_label_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
save_cells_label_function.FunctionArgs.FileRoot.Value=TrackStruct.ManFileRoot;
save_cells_label_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberFormat;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,save_cells_label_function);

image_read_loop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,image_read_loop);

global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();

%end function
end