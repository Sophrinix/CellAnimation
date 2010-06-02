function resegmentBlob(stage)

switch stage
    case 'initialize'
        intializeResegmentBlob();
    case 'complete'
        completeResegmentBlob();
end

%end resegmentBlob
end

function intializeResegmentBlob()
global msr_gui_struct;

selected_blob_id=msr_gui_struct.SelectedBlobID;
if isempty(selected_blob_id)
    warnDlg('No Blob is Selected');
    return;
end
msr_gui_struct.CurrentResegmentationIndex=1;
msr_gui_struct.SegmentationTrainingPoints=[];
msr_gui_struct.SegmentationGroups=[];
updateReviewSegGUIStatus('ResegmentBlob');

%end intializeResegmentBlob
end

function completeResegmentBlob()
global msr_gui_struct;

objects_lbl=msr_gui_struct.ObjectsLabel;
blobs_lbl=msr_gui_struct.BlobsLabel;
blob_id=msr_gui_struct.SelectedBlobID;
[blob_1 blob_2]=find(blobs_lbl==blob_id);
old_object_ids=unique(objects_lbl(blobs_lbl==blob_id));
old_objects_nr=length(old_object_ids);
training_points=msr_gui_struct.SegmentationTrainingPoints;
groups=msr_gui_struct.SegmentationGroups;
new_objects_nr=length(unique(groups));
img_sz=size(objects_lbl);
if (new_objects_nr>old_objects_nr)
    max_id=max(objects_lbl(:));
    new_object_ids=[old_object_ids max_id+(1:(new_objects_nr-old_objects_nr))];
    error_type='Undersegmentation';
elseif (new_objects_nr<old_objects_nr)
    new_object_ids=old_object_ids(1:new_objects_nr);
    error_type='Oversegmentation';
else
    new_object_ids=old_object_ids;
    error_type='Distribution';
end
training=[[training_points(:,1); training_points(:,1)-1; training_points(:,1)+1]...
    [training_points(:,2); training_points(:,2)-1; training_points(:,2)+1]];
groups=repmat(new_object_ids(groups),3,1);
segmentation_idx=knnclassify([blob_1 blob_2],training,groups);
for i=1:new_objects_nr
    cur_idx=segmentation_idx==new_object_ids(i);
    obj_coord_1=blob_1(cur_idx);
    obj_coord_2=blob_2(cur_idx);
    obj_coord_lin=sub2ind(img_sz,obj_coord_1,obj_coord_2);
    objects_lbl(obj_coord_lin)=new_object_ids(i);
end

msr_gui_struct.ObjectsLabel=objects_lbl;
image_handle=msr_gui_struct.ImageHandle;
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
set(image_handle,'CData',image_data);
addSegmentationError(error_type,blob_id);
updateReviewSegGUIStatus('SelectBlob');

%end completeResegmentBlob
end