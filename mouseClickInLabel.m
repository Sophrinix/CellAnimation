function []=mouseClickInLabel()
global msr_gui_struct;

axes_handle=msr_gui_struct.AxesHandle;
original_axes_units=get(axes_handle,'Units');
set(axes_handle,'Units','Pixels');
click_point = get(axes_handle,'CurrentPoint');
set(axes_handle,'Units',original_axes_units);

switch (msr_gui_struct.CurrentAction)
    case 'JoinObjects'
        addObject(click_point);
    case 'SelectBlob'
        selectBlob(click_point);
    case 'SelectObject'
        selectObject(click_point);
    case 'ResegmentBlob'
        addBlobCentroid(click_point);
    case 'RestoreBlob'
        selectBlobAndRestore(click_point);
    otherwise
        return;
end

%end mouseClickInLabel
end

function addObject(click_point)
global msr_gui_struct;

objects_lbl=msr_gui_struct.ObjectsLabel;
obj_id=objects_lbl(round(click_point(1,2)),round(click_point(1,1)));
image_handle=msr_gui_struct.ImageHandle;
image_data=get(image_handle,'CData');
if (obj_id==0)
    warnDlg('You clicked on the background!');
    msr_gui_struct.SelectedObjectID=[];
    set(image_handle,'CData',image_data);
    return;
end
join_ids=msr_gui_struct.JoinIDs;
cur_obj=objects_lbl==obj_id;
obj_mask=repmat(cur_obj,[1 1 3]);
if (max(join_ids==obj_id))
    %remove object from join list
    label_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    image_data(obj_mask)=label_rgb(obj_mask);
    join_ids(join_ids==obj_id)=[];
else
    %add object to join list    
    image_data(obj_mask)=createCheckerBoardPattern(cur_obj);
    join_ids=[join_ids; obj_id];
end
msr_gui_struct.JoinIDs=join_ids;
set(image_handle,'CData',image_data);
blobs_lbl=msr_gui_struct.BlobsLabel;
msr_gui_struct.SelectedObjectID=obj_id;
msr_gui_struct.SelectedBlobID=blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));

%end addObject
end

function selectBlob(click_point)
global msr_gui_struct;

blobs_lbl=msr_gui_struct.BlobsLabel;
blob_id=blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));
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
original_blobs_lbl=msr_gui_struct.OriginalBlobsLabel;
msr_gui_struct.OriginalBlobID=original_blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));

%end selectBlob
end

function selectObject(click_point)
global msr_gui_struct;

objects_lbl=msr_gui_struct.ObjectsLabel;
obj_id=objects_lbl(round(click_point(1,2)),round(click_point(1,1)));
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
blobs_lbl=msr_gui_struct.BlobsLabel;
msr_gui_struct.SelectedObjectID=obj_id;
msr_gui_struct.SelectedBlobID=blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));

%end selectObject
end

function addBlobCentroid(click_point)
global msr_gui_struct;

blobs_lbl=msr_gui_struct.BlobsLabel;
blob_id=blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));
if (blob_id~=msr_gui_struct.SelectedBlobID)
    warnDlg('You have not clicked on the selected blob!');   
    return;
end
msr_gui_struct.SegmentationTrainingPoints=[msr_gui_struct.SegmentationTrainingPoints;[click_point(1,2),click_point(1,1)]];
msr_gui_struct.SegmentationGroups=[msr_gui_struct.SegmentationGroups; msr_gui_struct.CurrentResegmentationIndex];

%end addBlobCentroid
end

function selectBlobAndRestore(click_point)
global msr_gui_struct;

original_blobs_lbl=msr_gui_struct.OriginalBlobsLabel;
original_objects_lbl=msr_gui_struct.OriginalObjectsLabel;
blobs_lbl=msr_gui_struct.BlobsLabel;
original_blob_id=original_blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));
blob_id=blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));
image_handle=msr_gui_struct.ImageHandle;
objects_lbl=msr_gui_struct.ObjectsLabel;
if (original_blob_id==0)
    warnDlg('You clicked on the background!');
    image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    set(image_handle,'CData',image_data);
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.ObjectsLabel=objects_lbl;
    msr_gui_struct.CurrentAction='SelectBlob';
    return;
end
if (blob_id~=0)
    warnDlg('The blob you clicked on exists. You need to delete a blob before you can restore it!');
    image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    set(image_handle,'CData',image_data);
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.ObjectsLabel=objects_lbl;
    msr_gui_struct.CurrentAction='SelectBlob';
    return;
end
%remove the blob errors
error_blob_ids=msr_gui_struct.ErrorBlobIDs;
blob_errors_idx=(error_blob_ids==original_blob_id);
other_errors_nr=sum(blob_errors_idx);
if (other_errors_nr)
    msr_gui_struct.TotalErrors=msr_gui_struct.TotalErrors-other_errors_nr;
    error_types=msr_gui_struct.ErrorTypes;
    error_types(blob_errors_idx)=[];
    msr_gui_struct.ErrorTypes=error_types;
    error_blob_ids(blob_errors_idx)=[];
    msr_gui_struct.ErrorBlobIDs=error_blob_ids;
end 

%restore the blob
original_blob=(original_blobs_lbl==original_blob_id);
objects_in_blob=original_objects_lbl(original_blob);
original_ids=unique(objects_in_blob);
max_id=max(objects_lbl(:));
new_ids=max_id+(1:length(original_ids));
%create an array to substitute the original ids with the new ids - make it
%sparse since we're not going to use most values
subs_array=sparse(max(original_ids),1);
subs_array(original_ids)=new_ids;
objects_lbl(original_blob)=subs_array(objects_in_blob);
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
set(image_handle,'CData',image_data);
msr_gui_struct.SelectedBlobID=[];
msr_gui_struct.ObjectsLabel=objects_lbl;
msr_gui_struct.BlobsLabel=bwlabeln(objects_lbl);
msr_gui_struct.CurrentAction='SelectBlob';

%end selectBlobAndRestore
end

function checkerboard_pattern=createCheckerBoardPattern(selected_object)

cur_obj_size=sum(selected_object(:));
checkerboard_pattern=repmat([0;intmax('uint8')],floor(cur_obj_size/2),1);
if (rem(cur_obj_size,2))
    checkerboard_pattern=[checkerboard_pattern;0];  
end
checkerboard_pattern=repmat(checkerboard_pattern,3,1);

%end createCheckerBoardPattern
end