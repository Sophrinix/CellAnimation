function output_args=manualSegmentationReview(input_args)
global msr_gui_struct;
msr_gui_struct=[];
objects_lbl=input_args.ObjectsLabel.Value;
msr_gui_struct.CurrentAction='';
msr_gui_struct.ObjectsLabel=objects_lbl;
msr_gui_struct.BlobsLabel=bwlabeln(objects_lbl>0);
msr_gui_struct.OriginalObjectsLabel=objects_lbl;
msr_gui_struct.OriginalBlobsLabel=msr_gui_struct.BlobsLabel;
%initialize the gui
msr_gui_struct.GuiHandle=manualSegmentationReviewGUI;
gui_handle=msr_gui_struct.GuiHandle;
children_handles=get(gui_handle,'children');
objects_rgb=label2rgb(objects_lbl); 
objects_axes_handle=findobj(children_handles,'tag','objectsAxes');
msr_gui_struct.AxesHandle=objects_axes_handle;
msr_gui_struct.SelectBlobButtonHandle=findobj(children_handles,'tag','selectBlobButton');
msr_gui_struct.SelectObjectButtonHandle=findobj(children_handles,'tag','selectObjectButton');
msr_gui_struct.ResegmentBlobButtonHandle=findobj(children_handles,'tag','resegmentBlobButton');
msr_gui_struct.RemoveBlobButtonHandle=findobj(children_handles,'tag','removeBlobButton');
msr_gui_struct.RestoreBlobButtonHandle=findobj(children_handles,'tag','restoreBlobButton');
msr_gui_struct.JoinObjectsButtonHandle=findobj(children_handles,'tag','joinObjectsButton');
msr_gui_struct.RemoveObjectButtonHandle=findobj(children_handles,'tag','removeObjectButton');

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