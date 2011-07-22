function []=mouseClickInLabel()
%helper function for manual segmentation review. detect mouse clicks and
%perform various actions
global msr_gui_struct;

axes_handle=msr_gui_struct.AxesHandle;
original_axes_units=get(axes_handle,'Units');
set(axes_handle,'Units','Pixels');
click_point = get(axes_handle,'CurrentPoint');
set(axes_handle,'Units',original_axes_units);

switch (msr_gui_struct.CurrentAction)
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



function selectBlob(click_point)
global msr_gui_struct;

blobs_lbl=msr_gui_struct.BlobsLabel;
blob_id=blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));
if ((blob_id==0) && msr_gui_struct.SnapToNearest)
   lbl_sz=size(blobs_lbl);
   nhood_sz=20;
   point11=max(1,(round(click_point(1,1)-nhood_sz)));   
   point12=min(lbl_sz(2),(round(click_point(1,1)+nhood_sz)));
   point21=max(1,(round(click_point(1,2)-nhood_sz)));
   point22=min(lbl_sz(1),(round(click_point(1,2)+nhood_sz)));
   nearby_frame=blobs_lbl(point21:point22,point11:point12);
   nearby_centroids=getApproximateCentroids(nearby_frame);
   nearby_ids=unique(nearby_frame);
   nearby_ids(1)=[];
   dist_1=nearby_centroids(nearby_ids,1)-click_point(1,1);
   dist_2=nearby_centroids(nearby_ids,2)-click_point(1,2);
   nearby_distances=sqrt(dist_1.^2+dist_2.^2);
   [dummy min_idx]=min(nearby_distances);
   click_point=nearby_centroids(nearby_ids(min_idx),:);
   blob_id=nearby_frame(round(click_point(1)),round(click_point(2)));
end
selectBlobByID(blob_id);
original_blobs_lbl=msr_gui_struct.OriginalBlobsLabel;
msr_gui_struct.OriginalBlobID=original_blobs_lbl(round(click_point(1,2)),round(click_point(1,1)));

%end selectBlob
end

function selectObject(click_point)
global msr_gui_struct;

objects_lbl=msr_gui_struct.ObjectsLabel;
obj_id=objects_lbl(round(click_point(1,2)),round(click_point(1,1)));

if ((obj_id==0) && msr_gui_struct.SnapToNearest)
   lbl_sz=size(objects_lbl);
   nhood_sz=20;
   point11=max(1,(round(click_point(1,1)-nhood_sz)));   
   point12=min(lbl_sz(2),(round(click_point(1,1)+nhood_sz)));
   point21=max(1,(round(click_point(1,2)-nhood_sz)));
   point22=min(lbl_sz(1),(round(click_point(1,2)+nhood_sz)));
   nearby_frame=objects_lbl(point21:point22,point11:point12);
   nearby_centroids=getApproximateCentroids(nearby_frame);
   nearby_ids=unique(nearby_frame);
   nearby_ids(1)=[];
   dist_1=nearby_centroids(nearby_ids,1)-click_point(1,1);
   dist_2=nearby_centroids(nearby_ids,2)-click_point(1,2);
   nearby_distances=sqrt(dist_1.^2+dist_2.^2);
   [dummy min_idx]=min(nearby_distances);
   click_point=nearby_centroids(nearby_ids(min_idx),:);
   obj_id=nearby_frame(round(click_point(1)),round(click_point(2)));
end
selectObjectByID(obj_id);

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