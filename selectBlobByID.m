function selectBlobByID(blob_id)
global msr_gui_struct;

blobs_lbl=msr_gui_struct.BlobsLabel;
image_handle=msr_gui_struct.ImageHandle;
objects_lbl=msr_gui_struct.ObjectsLabel;
if (blob_id==0)
    warnDlg('You clicked on the background!');
    msr_gui_struct.SelectedBlobID=[];
    image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    set(image_handle,'CData',image_data);
    return;
end

cur_blob=blobs_lbl==blob_id;
blob_mask=repmat(cur_blob,[1 1 3]);

if (msr_gui_struct.SelectMultiple)
    selected_blob_ids=msr_gui_struct.SelectedBlobID;
    if (max(selected_blob_ids==blob_id))
        %blob is already selected so unselect it
        selected_blob_ids(selected_blob_ids==blob_id)=[];
        msr_gui_struct.SelectedBlobID=selected_blob_ids;
        label_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
        image_data=get(image_handle,'CData');
        image_data(blob_mask)=label_rgb(blob_mask);
        set(image_handle,'CData',image_data);
    else
        image_data=get(image_handle,'CData');
        image_data(blob_mask)=createCheckerBoardPattern(cur_blob);
        set(image_handle,'CData',image_data);
        selected_blob_ids=[selected_blob_ids blob_id];
        msr_gui_struct.SelectedBlobID=selected_blob_ids;
    end    
else
    image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    image_data(blob_mask)=createCheckerBoardPattern(cur_blob);
    set(image_handle,'CData',image_data);
    msr_gui_struct.SelectedBlobID=blob_id;
end
 

msr_gui_struct.SelectedObjectID=[];

%end selectBlobByID
end