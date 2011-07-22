function output_args=manualSegmentationReview(input_args)
%manual segmentation review module. used to correct errors in automatic segmentation
global msr_gui_struct;

objects_lbl=input_args.ObjectsLabel.Value;
raw_lbl=input_args.RawLabel.Value;
previous_lbl=input_args.PreviousLabel.Value;
msr_gui_struct.ColorMap='colorcube';
msr_gui_struct.BkgColor=[0.7 0.7 0];
msr_gui_struct.ErrorTypes=[];
msr_gui_struct.ErrorBlobIDs=[];
msr_gui_struct.TotalErrors=0;
msr_gui_struct.CurrentAction='';
msr_gui_struct.ObjectsLabel=objects_lbl;
msr_gui_struct.BlobsLabel=bwlabeln(objects_lbl>0);
msr_gui_struct.OriginalObjectsLabel=raw_lbl;
msr_gui_struct.OriginalBlobsLabel=bwlabeln(raw_lbl>0);
msr_gui_struct.PreviousLabel=previous_lbl;
msr_gui_struct.Image=input_args.Image.Value;
msr_gui_struct.SelectMultiple=false;
msr_gui_struct.SelectedBlobID=[];
msr_gui_struct.SelectedObjectID=[];
msr_gui_struct.SnapToNearest=true;
%initialize the gui
field_names=fieldnames(msr_gui_struct);
gui_handle=findall(0,'Tag','ManualResegmentation');
if (~isempty(gui_handle))    
    close(gui_handle);    
end
if (max(strcmp('FigurePosition',field_names)))
    msr_gui_struct.GuiHandle=manualSegmentationReviewGUI('Position',msr_gui_struct.FigurePosition);
else
    msr_gui_struct.GuiHandle=manualSegmentationReviewGUI;    
end
gui_handle=msr_gui_struct.GuiHandle;
children_handles=get(gui_handle,'children');
objects_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle'); 
objects_axes_handle=findobj(children_handles,'tag','objectsAxes');
msr_gui_struct.AxesHandle=objects_axes_handle;
msr_gui_struct.SelectBlobButtonHandle=findobj(children_handles,'tag','selectBlobButton');
msr_gui_struct.SelectObjectButtonHandle=findobj(children_handles,'tag','selectObjectButton');
msr_gui_struct.ResegmentBlobButtonHandle=findobj(children_handles,'tag','resegmentBlobButton');
msr_gui_struct.RemoveBlobButtonHandle=findobj(children_handles,'tag','removeBlobButton');
msr_gui_struct.RestoreBlobButtonHandle=findobj(children_handles,'tag','restoreBlobButton');
msr_gui_struct.JoinObjectsButtonHandle=findobj(children_handles,'tag','joinObjectsButton');
msr_gui_struct.RemoveObjectButtonHandle=findobj(children_handles,'tag','removeObjectButton');
msr_gui_struct.StatusTextHandle=findobj(children_handles,'tag','statusText');
msr_gui_struct.CheckBoxPrevLabelHandle=findobj(children_handles,'tag','checkboxPrevLabel');
msr_gui_struct.CheckBoxOverlayPrevLabelHandle=findobj(children_handles,'tag','checkboxOverlayPrevLabel');
msr_gui_struct.CheckBoxSelectMultipleHandle=findobj(children_handles,'tag','checkboxSelectMultiple');
msr_gui_struct.CheckBoxSnapToNearestHandle=findobj(children_handles,'tag','checkboxSnapNearest');
if (isempty(previous_lbl))
    %disable show previous label checkbox
    set(msr_gui_struct.CheckBoxPrevLabelHandle,'Enable','off');
    msr_gui_struct.CheckBoxPrevLabelHandle=[];
    %disable overlay previous label checkbox
    set(msr_gui_struct.CheckBoxOverlayPrevLabelHandle,'Enable','off');
    msr_gui_struct.CheckBoxOverlayPrevLabelHandle=[];
end
msr_gui_struct.CheckBoxRawLabelHandle=findobj(children_handles,'tag','checkboxRawLabel');
msr_gui_struct.CheckBoxImageHandle=findobj(children_handles,'tag','checkboxImage');

%display objects image in the objectAxes
msr_gui_struct.ImageHandle=image(objects_rgb,'Parent',objects_axes_handle);
%set the function handle for a mouse click in the objects image
set(msr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInLabel');
set(msr_gui_struct.GuiHandle,'KeyPressFcn','keyPressInManualSegmentationGUI');
%block execution until gui is closed
waitfor(gui_handle);
output_args.LabelMatrix=msr_gui_struct.ObjectsLabel;

%end manualSegmentationReview
end