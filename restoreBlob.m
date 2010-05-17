function restoreBlob(hObject, eventdata, handles)
global msr_gui_struct;

msr_gui_struct.CurrentAction='RestoreBlob';
original_lbl=msr_gui_struct.OriginalObjectsLabel;
image_handle=msr_gui_struct.ImageHandle;
image_data=label2rgb(original_lbl);
set(image_handle,'CData',image_data);

%end restoreBlob
end