function removeBlob(hObject, eventdata, handles)
%helper function for manual segmentation review. remove the currently
%selected blob
global msr_gui_struct;

selected_blob_ids=msr_gui_struct.SelectedBlobID;
if isempty(selected_blob_ids)
    warnDlg('No Blob is Selected');
    return;
end
objects_lbl=msr_gui_struct.ObjectsLabel;
blobs_lbl=msr_gui_struct.BlobsLabel;
blob_idx=ismember(blobs_lbl,selected_blob_ids);
objects_lbl(blob_idx)=0;
blobs_lbl(blob_idx)=0;
msr_gui_struct.ObjectsLabel=objects_lbl;
msr_gui_struct.BlobsLabel=blobs_lbl;
addSegmentationError('BlobThresholding',selected_blob_ids);
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
image_handle=msr_gui_struct.ImageHandle;
set(image_handle,'CData',image_data);
msr_gui_struct.CurrentAction='SelectBlob';
msr_gui_struct.SelectedBlobID=[];

%end removeBlob
end