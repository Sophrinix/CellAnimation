function []=assayFlCytoLNCapTracksReviewWG()
%assayFlCytoLNCapTracksReviewWG - This assay is used to manually review the automatic tracks generated using a 
%tracking assay.  ImageFolder - String variable that specifies the absolute location of the 
%directory which contains the  time-lapse images. An example of such a string variable 
%would be 'c:/sample images/high-density'. ImageFilesRoot - String variable specifying the root image file name. 
%The root image file name  for a set of images is the image 
%file name of any of the  images without the number or the file 
%extension. For example, if the file name  is 'Experiment-0002_Position(8)_t021.tif' the root image file 
%name will be 'Experiment-0002_Position(8)_t'. ImageExtension - String variable specifying the image file extension including 
%the preceding dot. For example  if the file name is 'image003.jpg' the image 
%extension is '.jpg'. StartFrame - Number specifying the first image in the sequence to 
%be analyzed. The minimum  value for this variable depends on the numbering of 
%the image sequence so if  the first image in the sequence is 'image003.tif' 
%then the minimum value is 3. FrameCount - Number specifying how many images from 
%the image sequence should be processed. TimeFrame - Number specifying the time between consecutive 
%images in minutes. FrameStep - Number specifying the step size when reading images. Set 
%this variable to 1  to read every image in the sequence, 2 to 
%read every other image and  so on. NumberFormat - String value specifying the 
%number of digits in the image file names in  the sequence. For example 
%if the image file name is 'image020.jpg' the value for  the NumberFormat is 
%'%03d', while if the file name is 'image000020.jpg' the value should  be '%06d'. 
%MaxFramesMissing - Number specifying for how many frames a cell may be disappear before 
%its  track is ended. OutputFolder - The folder where the overlayed images and 
%track data will be saved. By  default this value is set to a 
%folder named 'output' within the folder where  the images to be analyzed are 
%located. AncestryFolder - The folder where the overlayed images and ancestry data will be 
%saved. By  default this value is set to a folder named 'ancestry' within 
%the output folder. AncestrySpreadsheet - The path name to the spreadsheet containing the ancestry 
%data. By default this  value is set to a file named 'ancestry.csv' within 
%the ancestry folder. ShapesSpreadsheet - The path name to the spreadsheet containing the position 
%and shape properties for  each cell in the timelapse sequence at every time 
%point. By default this is  set to to a file named 'shapes.csv' within 
%the ancestry folder. TracksFolder - The folder where the label matrixes containing the cell 
%outlines are saved. By  default this value is set to a folder named 
%'track' within the output folder. SegmentationFilesRoot - The root file name of the label 
%matrixes containing the cell outlines. ImageFileBase - The path name to the images. This 
%value is generated from the ImageFolder  and the ImageFilesRoot and should not be 
%changed. Important Modules - manualTrackingReview.

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