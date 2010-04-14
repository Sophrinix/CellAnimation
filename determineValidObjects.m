function [valid_segmentation_ids valid_len new_segmentation_idx]=determineValidObjects(segmentation_idx,...
    min_object_area,blob_1,blob_2)
%blobs smaller than our min threshold have to be unsegmented by assigning
%them to the nearest blob that is larger than minimum blob area

new_blob_areas=accumarray(segmentation_idx, 1);
segmentation_ids=[1:length(new_blob_areas)];
valid_new_blobs_idx=(new_blob_areas>min_object_area);
valid_areas=new_blob_areas(valid_new_blobs_idx);
valid_segmentation_ids=segmentation_ids(valid_new_blobs_idx);
new_segmentation_idx=[];
if isempty(valid_segmentation_ids)
    %no valid split
    valid_len=0;   
    return;
end
valid_len=length(valid_segmentation_ids);
if (valid_len==1)
    %only one of the blobs will be large enough so we can't split
    return;
end
invalid_segmentation_ids=segmentation_ids(~valid_new_blobs_idx);
if (~isempty(invalid_segmentation_ids))
    invalid_areas=new_blob_areas(~valid_new_blobs_idx);
    %calculate the centroids of the new valid blobs
    valid_centroids=zeros(valid_len,2);
    for i=1:valid_len
        cur_segmentation_id=valid_segmentation_ids(i);
        cur_area=valid_areas(i);
        cur_segmentation_idx=segmentation_idx==cur_segmentation_id;
        segmented_idx_1=blob_1(cur_segmentation_idx);
        segmented_idx_2=blob_2(cur_segmentation_idx);
        valid_centroids(i,:)=[sum(segmented_idx_1./cur_area) sum(segmented_idx_2./cur_area)];
    end
    invalid_len=length(invalid_segmentation_ids);
    %calculate the centroids of the new invalid blobs
    %reassign the invalid segmentations to their nearest valid neighbors
    new_segmentation_idx=segmentation_idx;
    for i=1:invalid_len
        cur_segmentation_id=invalid_segmentation_ids(i);
        cur_area=invalid_areas(i);
        cur_segmentation_idx=segmentation_idx==cur_segmentation_id;
        segmented_idx_1=blob_1(cur_segmentation_idx);
        segmented_idx_2=blob_2(cur_segmentation_idx);
        cur_centroid=[sum(segmented_idx_1./cur_area) sum(segmented_idx_2./cur_area)];
        dist_to_valid_centroids=hypot(valid_centroids(:,1)-cur_centroid(1),...
            valid_centroids(:,2)-cur_centroid(2));
        [dummy closest_valid_centroid_idx]=min(dist_to_valid_centroids);
        nearest_valid_id=valid_segmentation_ids(closest_valid_centroid_idx);
        new_segmentation_idx(segmentation_idx==cur_segmentation_id)=nearest_valid_id;
    end
end

%end determineValidObjects        
end