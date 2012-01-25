function joinObjects()
%helper function for manual segmentation review module. join objects in a
%label matrix to form a single possibly fragmented object.
global msr_gui_struct;

objects_lbl=msr_gui_struct.ObjectsLabel;
join_ids=sort(msr_gui_struct.SelectedObjectID);
join_ids_len=length(join_ids);
if (length(join_ids)<2)
    warnDlg('Multiple objects need to be selected!');
    return;
end

%set all the ids to the min id
for i=2:join_ids_len
    objects_lbl(objects_lbl==join_ids(i))=join_ids(1);    
end
image_handle=msr_gui_struct.ImageHandle;
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
set(image_handle,'CData',image_data);
msr_gui_struct.ObjectsLabel=objects_lbl;
updateReviewSegGUIStatus('SelectObject');

%end completeJoinObjects
end