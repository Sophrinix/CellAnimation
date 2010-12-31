function removeObject(hObject, eventdata, handles)
%helper function for manual segmentation review. remove selected object.
global msr_gui_struct;

selected_object_id=msr_gui_struct.SelectedObjectID;
if isempty(selected_object_id)
    warnDlg('No Object is Selected');
    return;
end
objects_lbl=msr_gui_struct.ObjectsLabel;
object_idx=objects_lbl==selected_object_id;
objects_lbl(object_idx)=0;
msr_gui_struct.ObjectsLabel=objects_lbl;
addSegmentationError('ObjectThresholding',msr_gui_struct.SelectedBlobID);
msr_gui_struct.BlobsLabel=bwlabeln(objects_lbl);
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
image_handle=msr_gui_struct.ImageHandle;
set(image_handle,'CData',image_data);

%end removeBlob
end