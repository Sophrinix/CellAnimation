function selectObjectByID(obj_id)
global msr_gui_struct;

objects_lbl=msr_gui_struct.BlobsLabel;
image_handle=msr_gui_struct.ImageHandle;

if (obj_id==0)
    warnDlg('You clicked on the background!');
    msr_gui_struct.SelectedObjectID=[];
    image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    set(image_handle,'CData',image_data);
    return;
end

cur_obj=objects_lbl==obj_id;
obj_mask=repmat(cur_obj,[1 1 3]);

if (msr_gui_struct.SelectMultiple)
    selected_obj_ids=msr_gui_struct.SelectedObjectID;
    if (max(selected_obj_ids==obj_id))
        %blob is already selected so unselect it
        selected_obj_ids(selected_obj_ids==obj_id)=[];
        msr_gui_struct.SelectedObjectID=selected_obj_ids;
        label_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
        image_data=get(image_handle,'CData');
        image_data(obj_mask)=label_rgb(obj_mask);
        set(image_handle,'CData',image_data);
    else
        image_data=get(image_handle,'CData');
        image_data(obj_mask)=createCheckerBoardPattern(cur_obj);
        set(image_handle,'CData',image_data);
        selected_obj_ids=[selected_obj_ids obj_id];
        msr_gui_struct.SelectedObjectID=selected_obj_ids;
    end    
else
    image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    image_data(obj_mask)=createCheckerBoardPattern(cur_obj);
    set(image_handle,'CData',image_data);
    msr_gui_struct.SelectedObjectID=obj_id;
end
 

msr_gui_struct.SelectedBlobID=[];



%end selectObjectByID
end