function output_args=manualTrackingReview(input_args)
global mtr_gui_struct;
mtr_gui_struct.TotalErrors=0;

%initialize the gui
field_names=fieldnames(mtr_gui_struct);
gui_handle=findall(0,'Tag','TrackingReview');
if (~isempty(gui_handle))    
    close(gui_handle);    
end
if (max(strcmp('FigurePosition',field_names)))
    mtr_gui_struct.GuiHandle=manualTrackingReviewGUI('Position',mtr_gui_struct.FigurePosition);
else
    mtr_gui_struct.GuiHandle=manualTrackingReviewGUI;    
end
gui_handle=mtr_gui_struct.GuiHandle;
children_handles=get(gui_handle,'children');
mtr_gui_struct.TracksHandle=findobj(children_handles,'tag','tracksAxes');
mtr_gui_struct.SliderHandle=findobj(children_handles,'tag','sliderTracks');
mtr_gui_struct.Tracks=input_args.Tracks.Value;
mtr_gui_struct.CellsAncestry=input_args.CellsAncestry.Value;
mtr_gui_struct.TimeFrame=input_args.TimeFrame.Value;
mtr_gui_struct.TracksLayout=input_args.TracksLayout.Value;
tracks_layout=mtr_gui_struct.TracksLayout;
mtr_gui_struct.TimeCol=tracks_layout.TimeCol;
mtr_gui_struct.TrackIDCol=tracks_layout.TrackIDCol;
mtr_gui_struct.MaxMissingFrames=input_args.MaxMissingFrames.Value;
mtr_gui_struct.FrameStep=input_args.FrameStep.Value;
mtr_gui_struct.ColorMap=input_args.ColorMap.Value;
mtr_gui_struct.AncestryLayout=input_args.AncestryLayout.Value;
mtr_gui_struct.FrameCount=input_args.FrameCount.Value;
mtr_gui_struct.ImageFileBase=input_args.ImageFileBase.Value;
mtr_gui_struct.NumberFormat=input_args.NumberFormat.Value;
mtr_gui_struct.ImgExt=input_args.ImgExt.Value;
mtr_gui_struct.SegFileRoot=input_args.SegFileRoot.Value;
mtr_gui_struct.StatusTextHandle=findobj(children_handles,'tag','statusText');
mtr_gui_struct.EditStatus1Handle=findobj(children_handles,'tag','editStatus1');
mtr_gui_struct.EditStatus2Handle=findobj(children_handles,'tag','editStatus2');
mtr_gui_struct.EditStatus3Handle=findobj(children_handles,'tag','editStatus3');
mtr_gui_struct.EditCellStatusHandle=findobj(children_handles,'tag','editStatusCell');
mtr_gui_struct.CheckBoxLabelsHandle=findobj(children_handles,'tag','checkboxLabels');
mtr_gui_struct.ButtonContinueTrackHandle=findobj(children_handles,'tag','buttonContinueTrack');
cur_frame=1;
mtr_gui_struct.CurFrame=cur_frame;
mtr_gui_struct.SelectedCellID=0;
mtr_gui_struct.SelectedCellLabelID=0;
mtr_gui_struct.ShowLabels=get(mtr_gui_struct.CheckBoxLabelsHandle,'Value');
mtr_gui_struct.ContinueTrack=false;

set(mtr_gui_struct.SliderHandle,'Min',cur_frame);
set(mtr_gui_struct.SliderHandle,'Max',mtr_gui_struct.FrameCount);
set(mtr_gui_struct.SliderHandle,'Value',cur_frame);
slider_step_size=1.0/double(mtr_gui_struct.FrameCount);
set(mtr_gui_struct.SliderHandle,'SliderStep',[slider_step_size min([10*slider_step_size 1])]);
%turn off the axes
set(mtr_gui_struct.GuiHandle,'DefaultAxesVisible','off');
set(mtr_gui_struct.StatusTextHandle,'String', ' Frame: 1 Mitotic Events Detected: 0');
set(mtr_gui_struct.EditStatus1Handle,'String', 'New Cells From Split:');
set(mtr_gui_struct.EditStatus2Handle,'String', 'Other New Cells In Frame:');
updateTrackImage(cur_frame,mtr_gui_struct.ShowLabels);
mtr_gui_struct.CurCentroids=getApproximateCentroids(mtr_gui_struct.CellsLabel);
%block execution until gui is closed
waitfor(gui_handle);
output_args.LabelMatrix=msr_gui_struct.ObjectsLabel;

%end manualTrackingReview
end