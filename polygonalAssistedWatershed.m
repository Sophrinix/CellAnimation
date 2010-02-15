function output_args=polygonalAssistedWatershed(input_args)

%allow the watershed to split only non-convex blobs

%determine bkg_ids - have to use area because ws_lbl splits the background
%in two or more pieces
nuclei_lbl=input_args.ImageLabel.Value;
nuclei_props=regionprops(nuclei_lbl,'Area');
nuclei_area=[nuclei_props.Area];
area_max=max(nuclei_area);
img_sz=size(nuclei_lbl);
ws_lbl=input_args.WatershedLabel.Value;
ws_props=regionprops(ws_lbl,'Area');
ws_area=[ws_props.Area];
bkg_mask=ismember(ws_lbl,find(ws_area>area_max));
ws_lbl(bkg_mask)=0;
% 
% 
nuclei_nr=max(nuclei_lbl(:));
convex_idx=input_args.ConvexObjectsIndex.Value;
min_nucl_area=input_args.MinBlobArea.Value;
for i=1:nuclei_nr
    if (convex_idx(i))
        %don't let the watershed split convex blobs
        continue;
    end
    cur_obj=nuclei_lbl==i;
    ws_lbl_obj=ws_lbl(cur_obj);
    ws_cluster_ids=unique(ws_lbl_obj);
    ws_cluster_ids=ws_cluster_ids(ws_cluster_ids>0);
    if(isempty(ws_cluster_ids))
        continue;
    end
    if (length(ws_cluster_ids)==1)
        %the blob is one colony no need to modify cyto_lbl
        continue;
    else
        nr_clusters=length(ws_cluster_ids);
        [blob_1 blob_2]=find(cur_obj);
        segmentation_idx=clusterdata([blob_1 blob_2], 'maxclust', nr_clusters, 'linkage', 'average');
        %get the areas of the newly segmented blobs
        new_blob_areas=accumarray(segmentation_idx, 1);
        %blobs smaller than our min threshold have to be unsegmented by assigning
        %them to the nearest blob that is larger than minimum blob area
        segmentation_ids=[1:length(new_blob_areas)];
        valid_new_blobs_idx=(new_blob_areas>min_nucl_area);
        valid_areas=new_blob_areas(valid_new_blobs_idx);
        valid_segmentation_ids=segmentation_ids(valid_new_blobs_idx);
        if isempty(valid_segmentation_ids)
            %no valid split
            continue;
        end
        valid_len=length(valid_segmentation_ids);
        if (valid_len==1)
            %only one of the blobs will be large enough so we can't split
            continue;
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
                segmentation_idx(segmentation_idx==cur_segmentation_id)=nearest_valid_id;
            end
        end
        nr_clusters=valid_len;        
        cur_max=max(nuclei_lbl(:));        
        for j=2:nr_clusters
            cur_idx=segmentation_idx==valid_segmentation_ids(j);
            cell_coord_1=blob_1(cur_idx);
            cell_coord_2=blob_2(cur_idx);
            cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
            nuclei_lbl(cell_coord_lin)=cur_max+j-1;
        end
    end    
end

output_args.LabelMatrix=nuclei_lbl;
%end polygonalAssistedWatershed
end