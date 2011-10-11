function []=assayFlCytoLNCapTracksReviewWG()
%Usage This assay is used to manually review the automatic tracks generated using a tracking 
%assay.

global functions_list;
functions_list=[];
%script variables
ImageFolder='C:/peter/cropped';
ImageFilesRoot='peter';
ImageExtension='.tif';
StartFrame=1;
FrameCount=9;
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
%end script variables


loadtrackslayout.InstanceName='LoadTracksLayout';
loadtrackslayout.FunctionHandle=@loadTracksLayout;
loadtrackslayout.FunctionArgs.FileName.Value='tracks_layout.mat';
functions_list=addToFunctionChain(functions_list,loadtrackslayout);

loadtracks.InstanceName='LoadTracks';
loadtracks.FunctionHandle=@loadTracks;
loadtracks.FunctionArgs.FileName.Value=[AncestryFolder '/tracks.mat'];
functions_list=addToFunctionChain(functions_list,loadtracks);

loadancestry.InstanceName='LoadAncestry';
loadancestry.FunctionHandle=@loadAncestry;
loadancestry.FunctionArgs.FileName.Value=[AncestryFolder '/ancestry.mat'];
functions_list=addToFunctionChain(functions_list,loadancestry);

loadcolormap.InstanceName='LoadColormap';
loadcolormap.FunctionHandle=@loadColormap;
loadcolormap.FunctionArgs.FileName.Value='colormap_lines';
functions_list=addToFunctionChain(functions_list,loadcolormap);

loadancestrylayout.InstanceName='LoadAncestryLayout';
loadancestrylayout.FunctionHandle=@loadAncestryLayout;
loadancestrylayout.FunctionArgs.FileName.Value='ancestry_layout.mat';
functions_list=addToFunctionChain(functions_list,loadancestrylayout);

manualtracksreview.InstanceName='ManualTracksReview';
manualtracksreview.FunctionHandle=@manualTrackingReview;
manualtracksreview.FunctionArgs.ImageFileBase.Value=ImageFileBase;
manualtracksreview.FunctionArgs.NumberFormat.Value=NumberFormat;
manualtracksreview.FunctionArgs.ImgExt.Value=ImageExtension;
manualtracksreview.FunctionArgs.TimeFrame.Value=TimeFrame;
manualtracksreview.FunctionArgs.TimeCol.Value=2;
manualtracksreview.FunctionArgs.TrackIDCol.Value=1;
manualtracksreview.FunctionArgs.MaxMissingFrames.Value=MaxFramesMissing;
manualtracksreview.FunctionArgs.FrameStep.Value=FrameStep;
manualtracksreview.FunctionArgs.SegFileRoot.Value=SegmentationFilesRoot;
manualtracksreview.FunctionArgs.FrameCount.Value=FrameCount;
manualtracksreview.FunctionArgs.StartFrame.Value=StartFrame;
manualtracksreview.FunctionArgs.Tracks.FunctionInstance='LoadTracks';
manualtracksreview.FunctionArgs.Tracks.OutputArg='Tracks';
manualtracksreview.FunctionArgs.CellsAncestry.FunctionInstance='LoadAncestry';
manualtracksreview.FunctionArgs.CellsAncestry.OutputArg='Ancestry';
manualtracksreview.FunctionArgs.ColorMap.FunctionInstance='LoadColormap';
manualtracksreview.FunctionArgs.ColorMap.OutputArg='Colormap';
manualtracksreview.FunctionArgs.TracksLayout.FunctionInstance='LoadTracksLayout';
manualtracksreview.FunctionArgs.TracksLayout.OutputArg='TracksLayout';
manualtracksreview.FunctionArgs.AncestryLayout.FunctionInstance='LoadAncestryLayout';
manualtracksreview.FunctionArgs.AncestryLayout.OutputArg='AncestryLayout';
functions_list=addToFunctionChain(functions_list,manualtracksreview);

saveupdatedtracks.InstanceName='SaveUpdatedTracks';
saveupdatedtracks.FunctionHandle=@saveTracks;
saveupdatedtracks.FunctionArgs.TracksFileName.Value=[AncestryFolder '/tracks.mat'];
saveupdatedtracks.FunctionArgs.Tracks.FunctionInstance='ManualTracksReview';
saveupdatedtracks.FunctionArgs.Tracks.OutputArg='Tracks';
functions_list=addToFunctionChain(functions_list,saveupdatedtracks);

saveancestry.InstanceName='SaveAncestry';
saveancestry.FunctionHandle=@saveAncestry;
saveancestry.FunctionArgs.AncestryFileName.Value=[AncestryFolder '/ancestry.mat'];
saveancestry.FunctionArgs.CellsAncestry.FunctionInstance='ManualTracksReview';
saveancestry.FunctionArgs.CellsAncestry.OutputArg='CellsAncestry';
functions_list=addToFunctionChain(functions_list,saveancestry);

saveancestryspreadsheets.InstanceName='SaveAncestrySpreadsheets';
saveancestryspreadsheets.FunctionHandle=@saveAncestrySpreadsheets;
saveancestryspreadsheets.FunctionArgs.ShapesXlsFile.Value=ShapesSpreadsheet;
saveancestryspreadsheets.FunctionArgs.ProlXlsFile.Value=AncestrySpreadsheet;
saveancestryspreadsheets.FunctionArgs.Tracks.FunctionInstance='ManualTracksReview';
saveancestryspreadsheets.FunctionArgs.Tracks.OutputArg='Tracks';
saveancestryspreadsheets.FunctionArgs.CellsAncestry.FunctionInstance='ManualTracksReview';
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