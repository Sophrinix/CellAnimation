function joinObjects(stage)

switch stage
    case 'initialize'
        intializeJoinObjects();
    case 'complete'
        completeJoinObjects();
end

%end joinObjects
end

function intializeJoinObjects()
global msr_gui_struct;

if (strcmp(msr_gui_struct.CurrentAction,'JoinObjects'))
    %already in the process of joining objects
    return;
end

selected_object_id=msr_gui_struct.SelectedObjectID;
if isempty(selected_object_id)
    warnDlg('No Object is Selected');
    return;
end
msr_gui_struct.JoinIDs=selected_object_id;
updateReviewSegGUIStatus('JoinObjects');

%end intializeJoinObjects
end

function completeJoinObjects()
global msr_gui_struct;

objects_lbl=msr_gui_struct.ObjectsLabel;
join_ids=sort(msr_gui_struct.JoinIDs);
max_id=max(objects_lbl(:));
join_ids_len=length(join_ids);
for i=2:join_ids_len
    objects_lbl(objects_lbl==join_ids(i))=join_ids(1);    
end
k=3;
for i=(join_ids(2)+1):max_id
    if (k<=join_ids_len)
        if (i==join_ids(k))
            k=k+1;
            continue;
        end
    end
    objects_lbl(objects_lbl==i)=i-k+2;
end
image_handle=msr_gui_struct.ImageHandle;
image_data=label2rgb(objects_lbl);
set(image_handle,'CData',image_data);
msr_gui_struct.ObjectsLabel=objects_lbl;
updateReviewSegGUIStatus('SelectObject');

%end completeJoinObjects
end