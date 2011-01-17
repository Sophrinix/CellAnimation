function selectObjectByID(obj_id)
global msr_gui_struct;
objects_lbl=msr_gui_struct.ObjectsLabel;
image_handle=msr_gui_struct.ImageHandle;
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
if (obj_id==0)
    warnDlg('You clicked on the background!');
    msr_gui_struct.SelectedObjectID=[];
    set(image_handle,'CData',image_data);
    return;
end
cur_obj=objects_lbl==obj_id;
obj_mask=repmat(cur_obj,[1 1 3]);
image_data(obj_mask)=createCheckerBoardPattern(cur_obj);
set(image_handle,'CData',image_data);
msr_gui_struct.SelectedObjectID=obj_id;


%end selectObjectByID
end