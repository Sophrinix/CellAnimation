function removeBlob(hObject, eventdata, handles)
global msr_gui_struct;

selected_blob_id=msr_gui_struct.SelectedBlobID;
if isempty(selected_blob_id)
    warnDlg('No Blob is Selected');
    return;
end
cells_lbl=msr_gui_struct.ObjectsLabel;
blobs_lbl=msr_gui_struct.BlobsLabel;
blob_idx=blobs_lbl==selected_blob_id;
cells_lbl(blob_idx)=0;
blobs_lbl(blob_idx)=0;
msr_gui_struct.ObjectsLabel=cells_lbl;
msr_gui_struct.BlobsLabel=blobs_lbl;
addSegmentationError('BlobThresholding',selected_blob_id);
image_data=label2rgb(cells_lbl);
image_handle=msr_gui_struct.ImageHandle;
set(image_handle,'CData',image_data);
msr_gui_struct.CurrentAction='SelectBlob';
msr_gui_struct.SelectedBlobID=[];

%end removeBlob
end