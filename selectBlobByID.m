function selectBlobByID(blob_id)
global msr_gui_struct;

blobs_lbl=msr_gui_struct.BlobsLabel;
image_handle=msr_gui_struct.ImageHandle;
objects_lbl=msr_gui_struct.ObjectsLabel;
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
if (blob_id==0)
    warnDlg('You clicked on the background!');
    msr_gui_struct.SelectedBlobID=[];
    set(image_handle,'CData',image_data);
    return;
end
cur_blob=blobs_lbl==blob_id;
blob_mask=repmat(cur_blob,[1 1 3]);
image_data(blob_mask)=createCheckerBoardPattern(cur_blob);
set(image_handle,'CData',image_data);
msr_gui_struct.SelectedObjectID=[];
msr_gui_struct.SelectedBlobID=blob_id;
%end selectBlobByID
end