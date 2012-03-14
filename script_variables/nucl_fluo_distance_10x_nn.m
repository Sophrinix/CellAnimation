%script variables
ImageFolder='C:/peter/cropped';
ImageFilesRoot='peter';
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
BrightnessThresholdPct=1.1;
ObjectArea=30;
Strel='disk';
StrelSize=10;
ClearBorder=true;
ClearBorderDist=2;
MedianFilterSize=3;
MinSolidity=0.69;
MinAreaOverPerimeter=1.5;
ResizeImageScale=0.5;
ResizeLabelMatrixScale=2;
ApproximationDistance=2.4;
MaxMergeDistance=23;
MaxSplitArea=400;
MaxSplitDistance=45;
MinSplitEccentricity=0.5;
MaxSplitEccentricity=0.95;
MinTimeForSplit=900;
MinLifespan=30;
%end script variables