function []=assayFlCytoLNCapTrackWG()
%assayFlCytoLNCapTrackWG - This assay is used to automatically track cells that have been segmented using 
% another assay.  ImageFolder - String variable that specifies the absolute location of 
%the  directory which contains the  time-lapse images. An example of such a 
%string variable  would be 'c:/sample images/high-density'. ImageFilesRoot - String variable specifying the root 
%image file name.  The root image file name  for a set of 
%images is the image  file name of any of the  images without 
%the number or the file  extension. For example, if the file name  
%is 'Experiment-0002_Position(8)_t021.tif' the root image file  name will be 'Experiment-0002_Position(8)_t'. ImageExtension - String 
%variable specifying the image file extension including  the preceding dot. For example  
%if the file name is 'image003.jpg' the image  extension is '.jpg'. StartFrame - 
%Number specifying the first image in the sequence to  be analyzed. The minimum 
% value for this variable depends on the numbering of  the image sequence 
%so if  the first image in the sequence is 'image003.tif'  then the 
%minimum value is 3. FrameCount - Number specifying how many images from  the 
%image sequence should be processed. TimeFrame - Number specifying the time between consecutive  
%images in minutes. FrameStep - Number specifying the step size when reading images. Set 
% this variable to 1  to read every image in the sequence, 2 
%to  read every other image and  so on. NumberFormat - String value 
%specifying the  number of digits in the image file names in  the 
%sequence. For example  if the image file name is 'image020.jpg' the value for 
% the NumberFormat is  '%03d', while if the file name is 'image000020.jpg' the 
%value should  be '%06d'.  MaxFramesMissing - Number specifying for how many frames 
%a cell may be disappear before  its  track is ended. OutputFolder - 
%The folder where the overlayed images and  track data will be saved. By 
% default this value is set to a  folder named 'output' within the 
%folder where  the images to be analyzed are  located. AncestryFolder - The 
%folder where the overlayed images and ancestry data will be  saved. By  
%default this value is set to a folder named 'ancestry' within  the output 
%folder. AncestrySpreadsheet - The path name to the spreadsheet containing the ancestry  data. 
%By default this  value is set to a file named 'ancestry.csv' within  
%the ancestry folder. ShapesSpreadsheet - The path name to the spreadsheet containing the position 
% and shape properties for  each cell in the timelapse sequence at every 
%time  point. By default this is  set to to a file named 
%'shapes.csv' within  the ancestry folder. TracksFolder - The folder where the label matrixes 
%containing the cell  outlines are saved. By  default this value is set 
%to a folder named  'track' within the output folder. SegmentationFilesRoot - The root 
%file name of the label  matrixes containing the cell outlines. ImageFileBase - The 
%path name to the images. This  value is generated from the ImageFolder  
%and the ImageFilesRoot and should not be  changed. MaxSearchRadius - Number specifying the 
%absolute lower bound for the search radius to  prevent selecting  too few 
%candidate objects for a track. Used by assignCellToTrackUsingAll module.  MinSearchRadius - Number specifying 
%the absolute higher bound for the search radius to prevent  selecting  too 
%many candidate objects for a track. Used by assignCellToTrackUsingAll module. MinSecondDistance  - Number 
%specifying the minimum significant distance between the closest candidate object to a   
%track and the second closest. Used to determine when distance should be used  
%as  a ranking parameter. Used by assignCellToTrackUsingAll module. MaxDistRatio - Number specifying the 
% maximum allowed distance ratio between the two nearest candidate objects.  If the 
%ratio  is higher than this value distance ranking will not be used.  
%Used by  assignCellToTrackUsingAll module. MaxAngleDiff - Number specifying the maximum allowed angle difference 
%between a track  and a candidate  object. If the angle is larger 
%than this value direction  ranking will not be  used for this object. 
%Used by assignCellToTrackUsingAll module. NrParamsForSureMatch  - Number specifying the minimum number of closest 
%matches between a candidate object parameters   and a track's object parameters that 
%make the candidate object a sure match  to  the track. Used by 
%assignCellToTrackUsingAll module. SearchRadiusPct - Number specifying the size  of the neighborhood from which 
%candidate objects for matching  the track are selected.  It is a multiple 
%of the distance to the nearest  candidate in the  current frame. Setting 
%this variable equal to 1 turns this module  into a  nearest-neighbor algorithm 
%(only the nearest cell can be a candidate). It does  not  make 
%sense to have a value lower than 1. Used by assignCellToTrackUsingAll module. MaxSplitArea  
%- Number specifying the maximum area a nucleus may be and still be considered 
%  as a part of a possible mitotic event. Used by detectMitoticEvents module. 
%MaxSplitDistance  - Number specifying the maximum distance a new nucleus may be from 
%another nucleus   and still be considered as part of a possible mitotic 
%event. Used by  detectMitoticEvents  module. MinSplitEccentricity - Number specifying the minimum eccentricity 
%a new nucleus may  have and still be  considered as part of 
%a possible mitotic event. Used  by detectMitoticEvents module. MaxSplitEccentricity - Number specifying the 
%maximum eccentricity a new nucleus may  have and still be  considered as 
%part of a possible mitotic event. Used  by detectMitoticEvents module. MinTimeForSplit - Number 
%specifying the minimum time in minutes a track  needs to exist before  
%it is considered for a possible mitotic event. Used  by detectMitoticEvents module. MinLifespan 
%- Number specifying the minimum length in frames a frame  has to be 
%to  not be removed by the removeShortTracks module. FrontParams -  Numeric array 
%specifying a set of column indices from the shape and motility   parameters 
%matrix. The parameters in those columns will be heavily weighted, and have more  
% influence in determining the best match for a track from a list of 
% objects.  Used by assignCellToTrackUsingAll module. DefaultParamWeights - Numeric array specifying a set 
%of  weights that is assigned to each shape  and motility parameter based 
%on its  prediction power. Parameters with high prediction power are  assigned high 
%weights and parameters  with low prediction power are assigned lower weights. Used  
%by assignCellToTrackUsingAll module. DistanceRankingOrder  - Numeric array specifying the default order of shape 
%and motility parameters for slow   moving objects when it cannot be determined 
%based on prediction power. Used by  assignCellToTrackUsingAll  module. DirectionRankingOrder - Numeric array 
%specifying the default order of shape and  motility parameters for fast  moving 
%directional objects when it cannot be determined based  on prediction power. Used by 
% assignCellToTrackUsingAll module. RelevantParametersIndex - Boolean array specifying column  indexes in the shape 
%and motility matrix that have  been determined to be  irrelevant for tracking. 
%This indicates to the module not to  use the parameters  those columns 
%in computing track assignment probabilities. The order of column  indexes is  provided 
%in TracksLayout variable. Used by assignCellToTrackUsingAll module. UnknownParamWeights - Numeric array specifying a  
%set of weights to be assigned to shape and  motility parameters when the 
% prediction power of the parameters cannot be determined. Used by  assignCellToTrackUsingAll module. 
%UnknownRankingOrder  - Numeric array specifying the order of the shape and motility parameters 
%when their   predictive power cannot be determined. If the objects cannot be 
%categorized as either  slow-moving  or fast directional the parameter order provided in 
%this variable is used.  Used by  assignCellToTrackUsingAll module. Important Modules - assignCellToTrackUsingAll, 
%detectMitoticEvents, splitTracks.

global functions_list;
functions_list=[];
%script variables
ImageFolder='C:/sample movies/low density';
ImageFilesRoot='low density sample';
ImageExtension='.tif';
StartFrame=1;
FrameCount=10;
TimeFrame=15;
FrameStep=1;
NumberFormat='%06d';
MaxFramesMissing=6;
OutputFolder=[ImageFolder '/output'];
AncestryFolder=[OutputFolder '/ancestry'];
AncestrySpreadsheet=[AncestryFolder 'ancestry.csv'];
ShapesSpreadsheet=[AncestryFolder 'shapes.csv'];
TracksFolder=[OutputFolder '/track'];
SegmentationFilesRoot=[TracksFolder '/grayscale'];
ImageFileBase=[ImageFolder '/' ImageFilesRoot];
MaxSearchRadius=Inf;
MinSearchRadius=0;
MinSecondDistance=5;
MaxDistRatio=0.6;
MaxAngleDiff=0.35;
NrParamsForSureMatch=5;
SearchRadiusPct=1.5;
MaxMergeDistance=23;
MaxSplitArea=400;
MaxSplitDistance=45;
MinSplitEccentricity=0.5;
MaxSplitEccentricity=0.95;
MinTimeForSplit=900;
MinLifespan=30;
FrontParams=[];
DefaultParamWeights=[34 21 13 8 5 3 2 2 2];
DistanceRankingOrder=[1 3 4 5 6 7 8 9 2];
DirectionRankingOrder=[2 3 4 5 6 7 8 9 1];
RelevantParametersIndex=[true true true false true false true true false];
UnknownParamWeights=[5 3 1 1 1 1 1 1 1];
UnknownRankingOrder=[1 2 3 4 5 6 7 8 9];
%end script variables

assign_cells_to_tracks_functions=[];
else_is_empty_cells_label_functions=[];
if_is_empty_cells_label_functions=[];
image_read_loop_functions=[];
image_overlay_loop_functions=[];

loadtrackslayout.InstanceName='LoadTracksLayout';
loadtrackslayout.FunctionHandle=@loadTracksLayout;
loadtrackslayout.FunctionArgs.FileName.Value='tracks_layout.mat';
functions_list=addToFunctionChain(functions_list,loadtrackslayout);

loadancestrylayout.InstanceName='LoadAncestryLayout';
loadancestrylayout.FunctionHandle=@loadAncestryLayout;
loadancestrylayout.FunctionArgs.FileName.Value='ancestry_layout.mat';
functions_list=addToFunctionChain(functions_list,loadancestrylayout);

displaycurframe.InstanceName='DisplayCurFrame';
displaycurframe.FunctionHandle=@displayVariable;
displaycurframe.FunctionArgs.VariableName.Value='Current Tracking Frame';
displaycurframe.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
displaycurframe.FunctionArgs.Variable.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,displaycurframe);

makelabelname.InstanceName='MakeLabelName';
makelabelname.FunctionHandle=@makeImgFileName;
makelabelname.FunctionArgs.FileBase.Value=SegmentationFilesRoot;
makelabelname.FunctionArgs.FileExt.Value='.mat';
makelabelname.FunctionArgs.NumberFmt.Value=NumberFormat;
makelabelname.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
makelabelname.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,makelabelname);

loadlabelmatrix.InstanceName='LoadLabelMatrix';
loadlabelmatrix.FunctionHandle=@loadCellsLabel;
loadlabelmatrix.FunctionArgs.FileName.FunctionInstance='MakeLabelName';
loadlabelmatrix.FunctionArgs.FileName.OutputArg='FileName';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,loadlabelmatrix);

getshapeparameters.InstanceName='GetShapeParameters';
getshapeparameters.FunctionHandle=@getShapeParams;
getshapeparameters.FunctionArgs.LabelMatrix.FunctionInstance='LoadLabelMatrix';
getshapeparameters.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,getshapeparameters);

isemptypreviouscellslabel.InstanceName='IsEmptyPreviousCellsLabel';
isemptypreviouscellslabel.FunctionHandle=@isEmptyFunction;
isemptypreviouscellslabel.FunctionArgs.TestVariable.Value=[];
isemptypreviouscellslabel.FunctionArgs.TestVariable.FunctionInstance='SaveCellsLabel';
isemptypreviouscellslabel.FunctionArgs.TestVariable.OutputArg='CellsLabel';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,isemptypreviouscellslabel);

starttracks.InstanceName='StartTracks';
starttracks.FunctionHandle=@startTracks;
starttracks.FunctionArgs.TimeFrame.Value=TimeFrame;
starttracks.FunctionArgs.CellsLabel.FunctionInstance='IfIsEmptyPreviousCellsLabel';
starttracks.FunctionArgs.CellsLabel.InputArg='LoadLabelMatrix_LabelMatrix';
starttracks.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
starttracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
starttracks.FunctionArgs.ShapeParameters.FunctionInstance='IfIsEmptyPreviousCellsLabel';
starttracks.FunctionArgs.ShapeParameters.InputArg='GetShapeParameters_ShapeParameters';
if_is_empty_cells_label_functions=addToFunctionChain(if_is_empty_cells_label_functions,starttracks);

getcurrenttracks.InstanceName='GetCurrentTracks';
getcurrenttracks.FunctionHandle=@getCurrentTracks;
getcurrenttracks.FunctionArgs.OffsetFrame.Value=-1;
getcurrenttracks.FunctionArgs.TimeFrame.Value=TimeFrame;
getcurrenttracks.FunctionArgs.TimeCol.Value=2;
getcurrenttracks.FunctionArgs.TrackIDCol.Value=1;
getcurrenttracks.FunctionArgs.MaxMissingFrames.Value=MaxFramesMissing;
getcurrenttracks.FunctionArgs.FrameStep.Value=FrameStep;
getcurrenttracks.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getcurrenttracks.FunctionArgs.Tracks.OutputArg='Tracks';
getcurrenttracks.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getcurrenttracks.FunctionArgs.Tracks.OutputArg2='Tracks';
getcurrenttracks.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
getcurrenttracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,getcurrenttracks);

getprevioustracks.InstanceName='GetPreviousTracks';
getprevioustracks.FunctionHandle=@getCurrentTracks;
getprevioustracks.FunctionArgs.OffsetFrame.Value=-2;
getprevioustracks.FunctionArgs.TimeFrame.Value=TimeFrame;
getprevioustracks.FunctionArgs.TimeCol.Value=2;
getprevioustracks.FunctionArgs.TrackIDCol.Value=1;
getprevioustracks.FunctionArgs.MaxMissingFrames.Value=MaxFramesMissing;
getprevioustracks.FunctionArgs.FrameStep.Value=FrameStep;
getprevioustracks.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getprevioustracks.FunctionArgs.Tracks.OutputArg='Tracks';
getprevioustracks.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getprevioustracks.FunctionArgs.Tracks.OutputArg2='Tracks';
getprevioustracks.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
getprevioustracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,getprevioustracks);

makeunassignedcellslist.InstanceName='MakeUnassignedCellsList';
makeunassignedcellslist.FunctionHandle=@makeUnassignedCellsList;
makeunassignedcellslist.FunctionArgs.CellsCentroids.FunctionInstance='IfIsEmptyPreviousCellsLabel';
makeunassignedcellslist.FunctionArgs.CellsCentroids.InputArg='GetShapeParameters_Centroids';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,makeunassignedcellslist);

makeexcludedtrackslist.InstanceName='MakeExcludedTracksList';
makeexcludedtrackslist.FunctionHandle=@makeExcludedTracksList;
makeexcludedtrackslist.FunctionArgs.UnassignedCellsIDs.FunctionInstance='MakeUnassignedCellsList';
makeexcludedtrackslist.FunctionArgs.UnassignedCellsIDs.OutputArg='UnassignedCellsIDs';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,makeexcludedtrackslist);

getcellsmeandisplacement.InstanceName='GetCellsMeanDisplacement';
getcellsmeandisplacement.FunctionHandle=@getObjectsMeanDisplacement;
getcellsmeandisplacement.FunctionArgs.Centroid1Col.Value=3;
getcellsmeandisplacement.FunctionArgs.Centroid2Col.Value=4;
getcellsmeandisplacement.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks';
getcellsmeandisplacement.FunctionArgs.CurrentTracks.OutputArg='Tracks';
getcellsmeandisplacement.FunctionArgs.ObjectCentroids.FunctionInstance='IfIsEmptyPreviousCellsLabel';
getcellsmeandisplacement.FunctionArgs.ObjectCentroids.InputArg='GetShapeParameters_Centroids';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,getcellsmeandisplacement);

getparamscoefficientofvariation.InstanceName='GetParamsCoefficientOfVariation';
getparamscoefficientofvariation.FunctionHandle=@getParamsCoefficientOfVariation;
getparamscoefficientofvariation.FunctionArgs.AreaCol.Value=5;
getparamscoefficientofvariation.FunctionArgs.SolidityCol.Value=11;
getparamscoefficientofvariation.FunctionArgs.Params.FunctionInstance='IfIsEmptyPreviousCellsLabel';
getparamscoefficientofvariation.FunctionArgs.Params.InputArg='GetShapeParameters_ShapeParameters';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,getparamscoefficientofvariation);

getmaxtrackid.InstanceName='GetMaxTrackID';
getmaxtrackid.FunctionHandle=@getMaxTrackID;
getmaxtrackid.FunctionArgs.TrackIDCol.Value=1;
getmaxtrackid.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getmaxtrackid.FunctionArgs.Tracks.OutputArg='Tracks';
getmaxtrackid.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getmaxtrackid.FunctionArgs.Tracks.OutputArg2='Tracks';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,getmaxtrackid);

isnotemptyunassignedcells.InstanceName='IsNotEmptyUnassignedCells';
isnotemptyunassignedcells.FunctionHandle=@isNotEmptyFunction;
isnotemptyunassignedcells.FunctionArgs.TestVariable.FunctionInstance='AssignCellToTrackUsingAll';
isnotemptyunassignedcells.FunctionArgs.TestVariable.OutputArg='UnassignedIDs';
isnotemptyunassignedcells.FunctionArgs.TestVariable.FunctionInstance2='AssignCellsToTracksLoop';
isnotemptyunassignedcells.FunctionArgs.TestVariable.InputArg2='MakeUnassignedCellsList_UnassignedCellsIDs';
assign_cells_to_tracks_functions=addToFunctionChain(assign_cells_to_tracks_functions,isnotemptyunassignedcells);

getcurrentunassignedcell.InstanceName='GetCurrentUnassignedCell';
getcurrentunassignedcell.FunctionHandle=@getCurrentUnassignedCell;
getcurrentunassignedcell.FunctionArgs.UnassignedCells.FunctionInstance='AssignCellToTrackUsingAll';
getcurrentunassignedcell.FunctionArgs.UnassignedCells.OutputArg='UnassignedIDs';
getcurrentunassignedcell.FunctionArgs.UnassignedCells.FunctionInstance2='AssignCellsToTracksLoop';
getcurrentunassignedcell.FunctionArgs.UnassignedCells.InputArg2='MakeUnassignedCellsList_UnassignedCellsIDs';
assign_cells_to_tracks_functions=addToFunctionChain(assign_cells_to_tracks_functions,getcurrentunassignedcell);

assigncelltotrackusingall.InstanceName='AssignCellToTrackUsingAll';
assigncelltotrackusingall.FunctionHandle=@assignCellToTrackUsingAll;
assigncelltotrackusingall.FunctionArgs.CheckCellPath.Value=true;
assigncelltotrackusingall.FunctionArgs.FrontParams.Value=FrontParams;
assigncelltotrackusingall.FunctionArgs.MaxSearchRadius.Value=MaxSearchRadius;
assigncelltotrackusingall.FunctionArgs.MinSearchRadius.Value=MinSearchRadius;
assigncelltotrackusingall.FunctionArgs.SearchRadiusPct.Value=SearchRadiusPct;
assigncelltotrackusingall.FunctionArgs.RelevantParametersIndex.Value=RelevantParametersIndex;
assigncelltotrackusingall.FunctionArgs.NrParamsForSureMatch.Value=NrParamsForSureMatch;
assigncelltotrackusingall.FunctionArgs.DefaultParamWeights.Value=DefaultParamWeights;
assigncelltotrackusingall.FunctionArgs.UnknownParamWeights.Value=UnknownParamWeights;
assigncelltotrackusingall.FunctionArgs.DistanceRankingOrder.Value=DistanceRankingOrder;
assigncelltotrackusingall.FunctionArgs.DirectionRankingOrder.Value=DirectionRankingOrder;
assigncelltotrackusingall.FunctionArgs.UnknownRankingOrder.Value=UnknownRankingOrder;
assigncelltotrackusingall.FunctionArgs.MinSecondDistance.Value=MinSecondDistance;
assigncelltotrackusingall.FunctionArgs.MaxDistRatio.Value=MaxDistRatio;
assigncelltotrackusingall.FunctionArgs.MaxAngleDiff.Value=MaxAngleDiff;
assigncelltotrackusingall.FunctionArgs.PreviousCellsLabel.Value=[];
assigncelltotrackusingall.FunctionArgs.TrackAssignments.Value=[];
assigncelltotrackusingall.FunctionArgs.MatchingGroups.Value=[];
assigncelltotrackusingall.FunctionArgs.MatchingGroupsStats.Value=[];
assigncelltotrackusingall.FunctionArgs.UnassignedCells.FunctionInstance='AssignCellToTrackUsingAll';
assigncelltotrackusingall.FunctionArgs.UnassignedCells.OutputArg='UnassignedIDs';
assigncelltotrackusingall.FunctionArgs.ExcludedTracks.FunctionInstance='AssignCellToTrackUsingAll';
assigncelltotrackusingall.FunctionArgs.ExcludedTracks.OutputArg='ExcludedTracks';
assigncelltotrackusingall.FunctionArgs.ShapeParameters.FunctionInstance='SetMatchingGroupIndex';
assigncelltotrackusingall.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters';
assigncelltotrackusingall.FunctionArgs.TrackAssignments.FunctionInstance='AssignCellToTrackUsingAll';
assigncelltotrackusingall.FunctionArgs.TrackAssignments.OutputArg='TrackAssignments';
assigncelltotrackusingall.FunctionArgs.MatchingGroups.FunctionInstance='AssignCellToTrackUsingAll';
assigncelltotrackusingall.FunctionArgs.MatchingGroups.OutputArg='MatchingGroups';
assigncelltotrackusingall.FunctionArgs.UnassignedCells.FunctionInstance2='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.UnassignedCells.InputArg2='MakeUnassignedCellsList_UnassignedCellsIDs';
assigncelltotrackusingall.FunctionArgs.ExcludedTracks.FunctionInstance2='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.ExcludedTracks.InputArg2='MakeExcludedTracksList_ExcludedTracks';
assigncelltotrackusingall.FunctionArgs.CellsLabel.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.CellsLabel.InputArg='LoadLabelMatrix_LabelMatrix';
assigncelltotrackusingall.FunctionArgs.PreviousCellsLabel.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.PreviousCellsLabel.InputArg='SaveCellsLabel_CellsLabel';
assigncelltotrackusingall.FunctionArgs.ShapeParameters.FunctionInstance2='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.ShapeParameters.InputArg2='GetShapeParameters_ShapeParameters';
assigncelltotrackusingall.FunctionArgs.CellsCentroids.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.CellsCentroids.InputArg='GetShapeParameters_Centroids';
assigncelltotrackusingall.FunctionArgs.CurrentTracks.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.CurrentTracks.InputArg='GetCurrentTracks_Tracks';
assigncelltotrackusingall.FunctionArgs.MaxTrackID.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.MaxTrackID.InputArg='GetMaxTrackID_MaxTrackID';
assigncelltotrackusingall.FunctionArgs.Tracks.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.Tracks.InputArg='IfIsEmptyPreviousCellsLabel_Tracks';
assigncelltotrackusingall.FunctionArgs.MatchingGroupsStats.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.MatchingGroupsStats.InputArg='GetMatchingGroupMeans_MatchingGroupStats';
assigncelltotrackusingall.FunctionArgs.ParamsCoeffOfVariation.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.ParamsCoeffOfVariation.InputArg='GetParamsCoefficientOfVariation_CoefficientOfVariation';
assigncelltotrackusingall.FunctionArgs.PreviousTracks.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.PreviousTracks.InputArg='GetPreviousTracks_Tracks';
assigncelltotrackusingall.FunctionArgs.TracksLayout.FunctionInstance='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
assigncelltotrackusingall.FunctionArgs.MatchingGroups.FunctionInstance2='AssignCellsToTracksLoop';
assigncelltotrackusingall.FunctionArgs.MatchingGroups.InputArg2='HoldMatchingGroups_ValueToHold';
assign_cells_to_tracks_functions=addToFunctionChain(assign_cells_to_tracks_functions,assigncelltotrackusingall);

setmatchinggroupindex.InstanceName='SetMatchingGroupIndex';
setmatchinggroupindex.FunctionHandle=@setGroupIndex;
setmatchinggroupindex.FunctionArgs.AreaCol.Value=5;
setmatchinggroupindex.FunctionArgs.GroupIDCol.Value=13;
setmatchinggroupindex.FunctionArgs.CellID.FunctionInstance='GetCurrentUnassignedCell';
setmatchinggroupindex.FunctionArgs.CellID.OutputArg='CellID';
setmatchinggroupindex.FunctionArgs.GroupIndex.FunctionInstance='AssignCellToTrackUsingAll';
setmatchinggroupindex.FunctionArgs.GroupIndex.OutputArg='GroupIndex';
setmatchinggroupindex.FunctionArgs.ShapeParameters.FunctionInstance='SetMatchingGroupIndex';
setmatchinggroupindex.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters';
setmatchinggroupindex.FunctionArgs.ShapeParameters.FunctionInstance2='AssignCellsToTracksLoop';
setmatchinggroupindex.FunctionArgs.ShapeParameters.InputArg2='GetShapeParameters_ShapeParameters';
assign_cells_to_tracks_functions=addToFunctionChain(assign_cells_to_tracks_functions,setmatchinggroupindex);

assigncellstotracksloop.InstanceName='AssignCellsToTracksLoop';
assigncellstotracksloop.FunctionHandle=@whileLoop;
assigncellstotracksloop.FunctionArgs.TestFunction.FunctionInstance='IsNotEmptyUnassignedCells';
assigncellstotracksloop.FunctionArgs.TestFunction.OutputArg='Boolean';
assigncellstotracksloop.FunctionArgs.MakeUnassignedCellsList_UnassignedCellsIDs.FunctionInstance='MakeUnassignedCellsList';
assigncellstotracksloop.FunctionArgs.MakeUnassignedCellsList_UnassignedCellsIDs.OutputArg='UnassignedCellsIDs';
assigncellstotracksloop.FunctionArgs.MakeExcludedTracksList_ExcludedTracks.FunctionInstance='MakeExcludedTracksList';
assigncellstotracksloop.FunctionArgs.MakeExcludedTracksList_ExcludedTracks.OutputArg='ExcludedTracks';
assigncellstotracksloop.FunctionArgs.GetCurrentTracks_Tracks.FunctionInstance='GetCurrentTracks';
assigncellstotracksloop.FunctionArgs.GetCurrentTracks_Tracks.OutputArg='Tracks';
assigncellstotracksloop.FunctionArgs.GetMaxTrackID_MaxTrackID.FunctionInstance='GetMaxTrackID';
assigncellstotracksloop.FunctionArgs.GetMaxTrackID_MaxTrackID.OutputArg='MaxTrackID';
assigncellstotracksloop.FunctionArgs.IfIsEmptyPreviousCellsLabel_Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.IfIsEmptyPreviousCellsLabel_Tracks.OutputArg='Tracks';
assigncellstotracksloop.FunctionArgs.GetMatchingGroupMeans_MatchingGroupStats.FunctionInstance='GetMatchingGroupMeans';
assigncellstotracksloop.FunctionArgs.GetMatchingGroupMeans_MatchingGroupStats.OutputArg='MatchingGroupStats';
assigncellstotracksloop.FunctionArgs.GetParamsCoefficientOfVariation_CoefficientOfVariation.FunctionInstance='GetParamsCoefficientOfVariation';
assigncellstotracksloop.FunctionArgs.GetParamsCoefficientOfVariation_CoefficientOfVariation.OutputArg='CoefficientOfVariation';
assigncellstotracksloop.FunctionArgs.GetPreviousTracks_Tracks.FunctionInstance='GetPreviousTracks';
assigncellstotracksloop.FunctionArgs.GetPreviousTracks_Tracks.OutputArg='Tracks';
assigncellstotracksloop.FunctionArgs.LoadLabelMatrix_LabelMatrix.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.LoadLabelMatrix_LabelMatrix.InputArg='LoadLabelMatrix_LabelMatrix';
assigncellstotracksloop.FunctionArgs.SaveCellsLabel_CellsLabel.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.SaveCellsLabel_CellsLabel.InputArg='SaveCellsLabel_CellsLabel';
assigncellstotracksloop.FunctionArgs.GetShapeParameters_ShapeParameters.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.GetShapeParameters_ShapeParameters.InputArg='GetShapeParameters_ShapeParameters';
assigncellstotracksloop.FunctionArgs.GetShapeParameters_Centroids.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.GetShapeParameters_Centroids.InputArg='GetShapeParameters_Centroids';
assigncellstotracksloop.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.LoadTracksLayout_TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
assigncellstotracksloop.FunctionArgs.HoldMatchingGroups_ValueToHold.FunctionInstance='IfIsEmptyPreviousCellsLabel';
assigncellstotracksloop.FunctionArgs.HoldMatchingGroups_ValueToHold.InputArg='HoldMatchingGroups_ValueToHold';
assigncellstotracksloop.KeepValues.AssignCellToTrackUsingAll_TrackAssignments.FunctionInstance='AssignCellToTrackUsingAll';
assigncellstotracksloop.KeepValues.AssignCellToTrackUsingAll_TrackAssignments.OutputArg='TrackAssignments';
assigncellstotracksloop.KeepValues.SetMatchingGroupIndex_ShapeParameters.FunctionInstance='SetMatchingGroupIndex';
assigncellstotracksloop.KeepValues.SetMatchingGroupIndex_ShapeParameters.OutputArg='ShapeParameters';
assigncellstotracksloop.KeepValues.AssignCellToTrackUsingAll_MatchingGroups.FunctionInstance='AssignCellToTrackUsingAll';
assigncellstotracksloop.KeepValues.AssignCellToTrackUsingAll_MatchingGroups.OutputArg='MatchingGroups';
assigncellstotracksloop.LoopFunctions=assign_cells_to_tracks_functions;
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,assigncellstotracksloop);

continuetracks.InstanceName='ContinueTracks';
continuetracks.FunctionHandle=@continueTracks;
continuetracks.FunctionArgs.TimeFrame.Value=TimeFrame;
continuetracks.FunctionArgs.Tracks.FunctionInstance='StartTracks';
continuetracks.FunctionArgs.Tracks.OutputArg='Tracks';
continuetracks.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
continuetracks.FunctionArgs.Tracks.OutputArg2='Tracks';
continuetracks.FunctionArgs.TrackAssignments.FunctionInstance='AssignCellsToTracksLoop';
continuetracks.FunctionArgs.TrackAssignments.OutputArg='AssignCellToTrackUsingAll_TrackAssignments';
continuetracks.FunctionArgs.ShapeParameters.FunctionInstance='AssignCellsToTracksLoop';
continuetracks.FunctionArgs.ShapeParameters.OutputArg='SetMatchingGroupIndex_ShapeParameters';
continuetracks.FunctionArgs.CurFrame.FunctionInstance='IfIsEmptyPreviousCellsLabel';
continuetracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
continuetracks.FunctionArgs.CellsCentroids.FunctionInstance='IfIsEmptyPreviousCellsLabel';
continuetracks.FunctionArgs.CellsCentroids.InputArg='GetShapeParameters_Centroids';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,continuetracks);

getmatchinggroupmeans.InstanceName='GetMatchingGroupMeans';
getmatchinggroupmeans.FunctionHandle=@getMatchingGroupMeans;
getmatchinggroupmeans.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getmatchinggroupmeans.FunctionArgs.Tracks.OutputArg='Tracks';
getmatchinggroupmeans.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getmatchinggroupmeans.FunctionArgs.Tracks.OutputArg2='Tracks';
getmatchinggroupmeans.FunctionArgs.TracksLayout.FunctionInstance='IfIsEmptyPreviousCellsLabel';
getmatchinggroupmeans.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
else_is_empty_cells_label_functions=addToFunctionChain(else_is_empty_cells_label_functions,getmatchinggroupmeans);

ifisemptypreviouscellslabel.InstanceName='IfIsEmptyPreviousCellsLabel';
ifisemptypreviouscellslabel.FunctionHandle=@if_statement;
ifisemptypreviouscellslabel.FunctionArgs.PreviousCellsLabel.Value=[];
ifisemptypreviouscellslabel.FunctionArgs.MatchingGroupsStats.Value=[];
ifisemptypreviouscellslabel.FunctionArgs.TrackAssignments.Value=[];
ifisemptypreviouscellslabel.FunctionArgs.TestVariable.FunctionInstance='IsEmptyPreviousCellsLabel';
ifisemptypreviouscellslabel.FunctionArgs.TestVariable.OutputArg='Boolean';
ifisemptypreviouscellslabel.FunctionArgs.LoadLabelMatrix_LabelMatrix.FunctionInstance='LoadLabelMatrix';
ifisemptypreviouscellslabel.FunctionArgs.LoadLabelMatrix_LabelMatrix.OutputArg='LabelMatrix';
ifisemptypreviouscellslabel.FunctionArgs.SegmentationLoop_LoopCounter.FunctionInstance='SegmentationLoop';
ifisemptypreviouscellslabel.FunctionArgs.SegmentationLoop_LoopCounter.OutputArg='LoopCounter';
ifisemptypreviouscellslabel.FunctionArgs.GetShapeParameters_ShapeParameters.FunctionInstance='GetShapeParameters';
ifisemptypreviouscellslabel.FunctionArgs.GetShapeParameters_ShapeParameters.OutputArg='ShapeParameters';
ifisemptypreviouscellslabel.FunctionArgs.GetShapeParameters_Centroids.FunctionInstance='GetShapeParameters';
ifisemptypreviouscellslabel.FunctionArgs.GetShapeParameters_Centroids.OutputArg='Centroids';
ifisemptypreviouscellslabel.FunctionArgs.SaveCellsLabel_CellsLabel.FunctionInstance='SaveCellsLabel';
ifisemptypreviouscellslabel.FunctionArgs.SaveCellsLabel_CellsLabel.OutputArg='CellsLabel';
ifisemptypreviouscellslabel.FunctionArgs.HoldMatchingGroups_ValueToHold.FunctionInstance='HoldMatchingGroups';
ifisemptypreviouscellslabel.FunctionArgs.HoldMatchingGroups_ValueToHold.OutputArg='ValueToHold';
ifisemptypreviouscellslabel.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='SegmentationLoop';
ifisemptypreviouscellslabel.FunctionArgs.LoadTracksLayout_TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
ifisemptypreviouscellslabel.KeepValues.AssignCellToTrackUsingAll_MatchingGroups.FunctionInstance='AssignCellsToTracksLoop';
ifisemptypreviouscellslabel.KeepValues.AssignCellToTrackUsingAll_MatchingGroups.OutputArg='AssignCellToTrackUsingAll_MatchingGroups';
ifisemptypreviouscellslabel.KeepValues.ContinueTracks_Tracks.FunctionInstance='ContinueTracks';
ifisemptypreviouscellslabel.KeepValues.ContinueTracks_Tracks.OutputArg='Tracks';
ifisemptypreviouscellslabel.ElseFunctions=else_is_empty_cells_label_functions;
ifisemptypreviouscellslabel.IfFunctions=if_is_empty_cells_label_functions;
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,ifisemptypreviouscellslabel);

savecellslabel.InstanceName='SaveCellsLabel';
savecellslabel.FunctionHandle=@saveCellsLabel;
savecellslabel.FunctionArgs.FileRoot.Value=SegmentationFilesRoot;
savecellslabel.FunctionArgs.NumberFormat.Value=NumberFormat;
savecellslabel.FunctionArgs.CellsLabel.FunctionInstance='LoadLabelMatrix';
savecellslabel.FunctionArgs.CellsLabel.OutputArg='LabelMatrix';
savecellslabel.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
savecellslabel.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,savecellslabel);

holdmatchinggroups.InstanceName='HoldMatchingGroups';
holdmatchinggroups.FunctionHandle=@holdValue;
holdmatchinggroups.FunctionArgs.ValueToHold.Value=[];
holdmatchinggroups.FunctionArgs.ValueToHold.FunctionInstance='IfIsEmptyPreviousCellsLabel';
holdmatchinggroups.FunctionArgs.ValueToHold.OutputArg='AssignCellToTrackUsingAll_MatchingGroups';
image_read_loop_functions=addToFunctionChain(image_read_loop_functions,holdmatchinggroups);

segmentationloop.InstanceName='SegmentationLoop';
segmentationloop.FunctionHandle=@forLoop;
segmentationloop.FunctionArgs.StartLoop.Value=StartFrame;
segmentationloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
segmentationloop.FunctionArgs.IncrementLoop.Value=FrameStep;
segmentationloop.FunctionArgs.MatchingGroups.Value=[];
segmentationloop.FunctionArgs.Tracks.Value=[];
segmentationloop.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='LoadTracksLayout';
segmentationloop.FunctionArgs.LoadTracksLayout_TracksLayout.OutputArg='TracksLayout';
segmentationloop.KeepValues.ContinueTracks_Tracks.FunctionInstance='IfIsEmptyPreviousCellsLabel';
segmentationloop.KeepValues.ContinueTracks_Tracks.OutputArg='ContinueTracks_Tracks';
segmentationloop.LoopFunctions=image_read_loop_functions;
functions_list=addToFunctionChain(functions_list,segmentationloop);

savetracks.InstanceName='SaveTracks';
savetracks.FunctionHandle=@saveTracks;
savetracks.FunctionArgs.TracksFileName.Value=[TracksFolder '/tracks.mat'];
savetracks.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
savetracks.FunctionArgs.Tracks.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,savetracks);

gettrackids.InstanceName='GetTrackIDs';
gettrackids.FunctionHandle=@getTrackIDs;
gettrackids.FunctionArgs.TrackIDCol.Value=1;
gettrackids.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
gettrackids.FunctionArgs.Tracks.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,gettrackids);

detectmergecandidates.InstanceName='DetectMergeCandidates';
detectmergecandidates.FunctionHandle=@detectMergeCandidatesUsingDistance;
detectmergecandidates.FunctionArgs.MaxMergeDistance.Value=MaxMergeDistance;
detectmergecandidates.FunctionArgs.TrackIDs.FunctionInstance='GetTrackIDs';
detectmergecandidates.FunctionArgs.TrackIDs.OutputArg='TrackIDs';
detectmergecandidates.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
detectmergecandidates.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
detectmergecandidates.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
detectmergecandidates.FunctionArgs.Tracks.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,detectmergecandidates);

mergetracks.InstanceName='MergeTracks';
mergetracks.FunctionHandle=@mergeTracks;
mergetracks.FunctionArgs.FrameCount.Value=FrameCount;
mergetracks.FunctionArgs.StartFrame.Value=StartFrame;
mergetracks.FunctionArgs.TimeFrame.Value=TimeFrame;
mergetracks.FunctionArgs.SegFileRoot.Value=SegmentationFilesRoot;
mergetracks.FunctionArgs.FrameStep.Value=FrameStep;
mergetracks.FunctionArgs.NumberFormat.Value=NumberFormat;
mergetracks.FunctionArgs.TracksToBeMerged.FunctionInstance='DetectMergeCandidates';
mergetracks.FunctionArgs.TracksToBeMerged.OutputArg='TracksToBeMerged';
mergetracks.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
mergetracks.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
mergetracks.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
mergetracks.FunctionArgs.Tracks.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,mergetracks);

gettrackidsaftermerge.InstanceName='GetTrackIDsAfterMerge';
gettrackidsaftermerge.FunctionHandle=@getTrackIDs;
gettrackidsaftermerge.FunctionArgs.TrackIDCol.Value=1;
gettrackidsaftermerge.FunctionArgs.Tracks.FunctionInstance='MergeTracks';
gettrackidsaftermerge.FunctionArgs.Tracks.OutputArg='Tracks';
functions_list=addToFunctionChain(functions_list,gettrackidsaftermerge);

makeancestryforfirstframecells.InstanceName='MakeAncestryForFirstFrameCells';
makeancestryforfirstframecells.FunctionHandle=@makeAncestryForFirstFrameCells;
makeancestryforfirstframecells.FunctionArgs.TimeCol.Value=2;
makeancestryforfirstframecells.FunctionArgs.TrackIDCol.Value=1;
makeancestryforfirstframecells.FunctionArgs.Tracks.FunctionInstance='MergeTracks';
makeancestryforfirstframecells.FunctionArgs.Tracks.OutputArg='Tracks';
makeancestryforfirstframecells.FunctionArgs.TrackIDs.FunctionInstance='GetTrackIDsAfterMerge';
makeancestryforfirstframecells.FunctionArgs.TrackIDs.OutputArg='TrackIDs';
functions_list=addToFunctionChain(functions_list,makeancestryforfirstframecells);

detectmitoticevents.InstanceName='DetectMitoticEvents';
detectmitoticevents.FunctionHandle=@detectMitoticEvents;
detectmitoticevents.FunctionArgs.MaxSplitArea.Value=MaxSplitArea;
detectmitoticevents.FunctionArgs.MinSplitEccentricity.Value=MinSplitEccentricity;
detectmitoticevents.FunctionArgs.MaxSplitEccentricity.Value=MaxSplitEccentricity;
detectmitoticevents.FunctionArgs.MaxSplitDistance.Value=MaxSplitDistance;
detectmitoticevents.FunctionArgs.MinTimeForSplit.Value=MinTimeForSplit;
detectmitoticevents.FunctionArgs.Tracks.FunctionInstance='MergeTracks';
detectmitoticevents.FunctionArgs.Tracks.OutputArg='Tracks';
detectmitoticevents.FunctionArgs.UntestedIDs.FunctionInstance='MakeAncestryForFirstFrameCells';
detectmitoticevents.FunctionArgs.UntestedIDs.OutputArg='UntestedIDs';
detectmitoticevents.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
detectmitoticevents.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
functions_list=addToFunctionChain(functions_list,detectmitoticevents);

makeancestryforcellsenteringframes.InstanceName='MakeAncestryForCellsEnteringFrames';
makeancestryforcellsenteringframes.FunctionHandle=@makeAncestryForCellsEnteringFrames;
makeancestryforcellsenteringframes.FunctionArgs.TimeCol.Value=2;
makeancestryforcellsenteringframes.FunctionArgs.TrackIDCol.Value=1;
makeancestryforcellsenteringframes.FunctionArgs.SplitCells.FunctionInstance='DetectMitoticEvents';
makeancestryforcellsenteringframes.FunctionArgs.SplitCells.OutputArg='SplitCells';
makeancestryforcellsenteringframes.FunctionArgs.TrackIDs.FunctionInstance='GetTrackIDsAfterMerge';
makeancestryforcellsenteringframes.FunctionArgs.TrackIDs.OutputArg='TrackIDs';
makeancestryforcellsenteringframes.FunctionArgs.FirstFrameIDs.FunctionInstance='MakeAncestryForFirstFrameCells';
makeancestryforcellsenteringframes.FunctionArgs.FirstFrameIDs.OutputArg='FirstFrameIDs';
makeancestryforcellsenteringframes.FunctionArgs.CellsAncestry.FunctionInstance='MakeAncestryForFirstFrameCells';
makeancestryforcellsenteringframes.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
makeancestryforcellsenteringframes.FunctionArgs.Tracks.FunctionInstance='MergeTracks';
makeancestryforcellsenteringframes.FunctionArgs.Tracks.OutputArg='Tracks';
functions_list=addToFunctionChain(functions_list,makeancestryforcellsenteringframes);

splittracks.InstanceName='SplitTracks';
splittracks.FunctionHandle=@splitTracks;
splittracks.FunctionArgs.TimeFrame.Value=TimeFrame;
splittracks.FunctionArgs.SplitCells.FunctionInstance='DetectMitoticEvents';
splittracks.FunctionArgs.SplitCells.OutputArg='SplitCells';
splittracks.FunctionArgs.Tracks.FunctionInstance='MergeTracks';
splittracks.FunctionArgs.Tracks.OutputArg='Tracks';
splittracks.FunctionArgs.CellsAncestry.FunctionInstance='MakeAncestryForCellsEnteringFrames';
splittracks.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
splittracks.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
splittracks.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
splittracks.FunctionArgs.AncestryLayout.FunctionInstance='LoadAncestryLayout';
splittracks.FunctionArgs.AncestryLayout.OutputArg='AncestryLayout';
functions_list=addToFunctionChain(functions_list,splittracks);

removeshorttracks.InstanceName='RemoveShortTracks';
removeshorttracks.FunctionHandle=@removeShortTracks;
removeshorttracks.FunctionArgs.MinLifespan.Value=MinLifespan;
removeshorttracks.FunctionArgs.Tracks.FunctionInstance='SplitTracks';
removeshorttracks.FunctionArgs.Tracks.OutputArg='Tracks';
removeshorttracks.FunctionArgs.CellsAncestry.FunctionInstance='SplitTracks';
removeshorttracks.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
removeshorttracks.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
removeshorttracks.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
removeshorttracks.FunctionArgs.AncestryLayout.FunctionInstance='LoadAncestryLayout';
removeshorttracks.FunctionArgs.AncestryLayout.OutputArg='AncestryLayout';
functions_list=addToFunctionChain(functions_list,removeshorttracks);

saveupdatedtracks.InstanceName='SaveUpdatedTracks';
saveupdatedtracks.FunctionHandle=@saveTracks;
saveupdatedtracks.FunctionArgs.TracksFileName.Value=[AncestryFolder '/tracks.mat'];
saveupdatedtracks.FunctionArgs.Tracks.FunctionInstance='RemoveShortTracks';
saveupdatedtracks.FunctionArgs.Tracks.OutputArg='Tracks';
functions_list=addToFunctionChain(functions_list,saveupdatedtracks);

saveancestry.InstanceName='SaveAncestry';
saveancestry.FunctionHandle=@saveAncestry;
saveancestry.FunctionArgs.AncestryFileName.Value=[AncestryFolder '/ancestry.mat'];
saveancestry.FunctionArgs.CellsAncestry.FunctionInstance='RemoveShortTracks';
saveancestry.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
functions_list=addToFunctionChain(functions_list,saveancestry);

makeimagenamesinoverlayloop.InstanceName='MakeImageNamesInOverlayLoop';
makeimagenamesinoverlayloop.FunctionHandle=@makeImgFileName;
makeimagenamesinoverlayloop.FunctionArgs.FileBase.Value=ImageFileBase;
makeimagenamesinoverlayloop.FunctionArgs.NumberFmt.Value=NumberFormat;
makeimagenamesinoverlayloop.FunctionArgs.FileExt.Value=ImageExtension;
makeimagenamesinoverlayloop.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
makeimagenamesinoverlayloop.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,makeimagenamesinoverlayloop);

readimagesinoverlayloop.InstanceName='ReadImagesInOverlayLoop';
readimagesinoverlayloop.FunctionHandle=@readImage;
readimagesinoverlayloop.FunctionArgs.ImageChannel.Value='';
readimagesinoverlayloop.FunctionArgs.ImageName.FunctionInstance='MakeImageNamesInOverlayLoop';
readimagesinoverlayloop.FunctionArgs.ImageName.OutputArg='FileName';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,readimagesinoverlayloop);

getcurrenttracks2.InstanceName='GetCurrentTracks2';
getcurrenttracks2.FunctionHandle=@getCurrentTracks;
getcurrenttracks2.FunctionArgs.OffsetFrame.Value=0;
getcurrenttracks2.FunctionArgs.TimeFrame.Value=TimeFrame;
getcurrenttracks2.FunctionArgs.TimeCol.Value=2;
getcurrenttracks2.FunctionArgs.TrackIDCol.Value=1;
getcurrenttracks2.FunctionArgs.MaxMissingFrames.Value=0;
getcurrenttracks2.FunctionArgs.FrameStep.Value=FrameStep;
getcurrenttracks2.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
getcurrenttracks2.FunctionArgs.CurFrame.OutputArg='LoopCounter';
getcurrenttracks2.FunctionArgs.Tracks.FunctionInstance='ImageOverlayLoop';
getcurrenttracks2.FunctionArgs.Tracks.InputArg='RemoveShortTracks_Tracks';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,getcurrenttracks2);

makematnamesinoverlayloop.InstanceName='MakeMatNamesInOverlayLoop';
makematnamesinoverlayloop.FunctionHandle=@makeImgFileName;
makematnamesinoverlayloop.FunctionArgs.FileBase.Value=SegmentationFilesRoot;
makematnamesinoverlayloop.FunctionArgs.NumberFmt.Value=NumberFormat;
makematnamesinoverlayloop.FunctionArgs.FileExt.Value='.mat';
makematnamesinoverlayloop.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
makematnamesinoverlayloop.FunctionArgs.CurFrame.OutputArg='LoopCounter';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,makematnamesinoverlayloop);

loadcellslabel.InstanceName='LoadCellsLabel';
loadcellslabel.FunctionHandle=@loadCellsLabel;
loadcellslabel.FunctionArgs.FileName.FunctionInstance='MakeMatNamesInOverlayLoop';
loadcellslabel.FunctionArgs.FileName.OutputArg='FileName';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,loadcellslabel);

loadcolormap.InstanceName='LoadColormap';
loadcolormap.FunctionHandle=@loadColormap;
loadcolormap.FunctionArgs.FileName.Value='colormap_lines';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,loadcolormap);

displayoverlayingframe.InstanceName='DisplayOverlayingFrame';
displayoverlayingframe.FunctionHandle=@displayVariable;
displayoverlayingframe.FunctionArgs.VariableName.Value='Overlaying Frame';
displayoverlayingframe.FunctionArgs.Variable.FunctionInstance='ImageOverlayLoop';
displayoverlayingframe.FunctionArgs.Variable.OutputArg='LoopCounter';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,displayoverlayingframe);

displayancestry.InstanceName='DisplayAncestry';
displayancestry.FunctionHandle=@displayAncestryData;
displayancestry.FunctionArgs.NumberFormat.Value=NumberFormat;
displayancestry.FunctionArgs.ProlDir.Value=AncestryFolder;
displayancestry.FunctionArgs.ImageFileName.Value=ImageFilesRoot;
displayancestry.FunctionArgs.DS.Value='/';
displayancestry.FunctionArgs.Image.FunctionInstance='ReadImagesInOverlayLoop';
displayancestry.FunctionArgs.Image.OutputArg='Image';
displayancestry.FunctionArgs.CurrentTracks.FunctionInstance='GetCurrentTracks2';
displayancestry.FunctionArgs.CurrentTracks.OutputArg='Tracks';
displayancestry.FunctionArgs.CellsLabel.FunctionInstance='LoadCellsLabel';
displayancestry.FunctionArgs.CellsLabel.OutputArg='LabelMatrix';
displayancestry.FunctionArgs.CurFrame.FunctionInstance='ImageOverlayLoop';
displayancestry.FunctionArgs.CurFrame.OutputArg='LoopCounter';
displayancestry.FunctionArgs.ColorMap.FunctionInstance='LoadColormap';
displayancestry.FunctionArgs.ColorMap.OutputArg='Colormap';
displayancestry.FunctionArgs.CellsAncestry.FunctionInstance='ImageOverlayLoop';
displayancestry.FunctionArgs.CellsAncestry.InputArg='RemoveShortTracks_CellsAncestry';
displayancestry.FunctionArgs.TracksLayout.FunctionInstance='ImageOverlayLoop';
displayancestry.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
displayancestry.FunctionArgs.AncestryLayout.FunctionInstance='ImageOverlayLoop';
displayancestry.FunctionArgs.AncestryLayout.InputArg='LoadAncestryLayout_AncestryLayout';
image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,displayancestry);

imageoverlayloop.InstanceName='ImageOverlayLoop';
imageoverlayloop.FunctionHandle=@forLoop;
imageoverlayloop.FunctionArgs.StartLoop.Value=StartFrame;
imageoverlayloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
imageoverlayloop.FunctionArgs.IncrementLoop.Value=FrameStep;
imageoverlayloop.FunctionArgs.RemoveShortTracks_Tracks.FunctionInstance='RemoveShortTracks';
imageoverlayloop.FunctionArgs.RemoveShortTracks_Tracks.OutputArg='Tracks';
imageoverlayloop.FunctionArgs.RemoveShortTracks_CellsAncestry.FunctionInstance='RemoveShortTracks';
imageoverlayloop.FunctionArgs.RemoveShortTracks_CellsAncestry.OutputArg='CellsAncestry';
imageoverlayloop.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='LoadTracksLayout';
imageoverlayloop.FunctionArgs.LoadTracksLayout_TracksLayout.OutputArg='TracksLayout';
imageoverlayloop.FunctionArgs.LoadAncestryLayout_AncestryLayout.FunctionInstance='LoadAncestryLayout';
imageoverlayloop.FunctionArgs.LoadAncestryLayout_AncestryLayout.OutputArg='AncestryLayout';
imageoverlayloop.LoopFunctions=image_overlay_loop_functions;
functions_list=addToFunctionChain(functions_list,imageoverlayloop);

saveancestryspreadsheets.InstanceName='SaveAncestrySpreadsheets';
saveancestryspreadsheets.FunctionHandle=@saveAncestrySpreadsheets;
saveancestryspreadsheets.FunctionArgs.ShapesXlsFile.Value=ShapesSpreadsheet;
saveancestryspreadsheets.FunctionArgs.ProlXlsFile.Value=AncestrySpreadsheet;
saveancestryspreadsheets.FunctionArgs.Tracks.FunctionInstance='RemoveShortTracks';
saveancestryspreadsheets.FunctionArgs.Tracks.OutputArg='Tracks';
saveancestryspreadsheets.FunctionArgs.CellsAncestry.FunctionInstance='RemoveShortTracks';
saveancestryspreadsheets.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
saveancestryspreadsheets.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
saveancestryspreadsheets.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
functions_list=addToFunctionChain(functions_list,saveancestryspreadsheets);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end