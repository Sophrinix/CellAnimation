function removeObject(hObject, eventdata, handles)
global msr_gui_struct;

selected_object_id=msr_gui_struct.SelectedObjectID;
if isempty(selected_object_id)
    warnDlg('No Object is Selected');
    return;
end
cells_lbl=msr_gui_struct.ObjectsLabel;
object_idx=cells_lbl==selected_object_id;
cells_lbl(object_idx)=0;
msr_gui_struct.ObjectsLabel=cells_lbl;
msr_gui_struct.BlobsLabel=bwlabeln(cells_lbl);
image_data=label2rgb(cells_lbl);
image_handle=msr_gui_struct.ImageHandle;
set(image_handle,'CData',image_data);

%end removeBlob
end