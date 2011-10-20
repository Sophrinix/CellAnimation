function output_args=polygonalAssistedWatershed(input_args)
% Usage
% This module is used to prevent a watershed segmentation module (can be another type of segmentation module) from splitting convex objects. The assumption is that convex objects are atomic and should not be split. This assumption works well for nuclear stains.
% Input Structure Members
% ConvexObjectsIndex – List containing the index of convex objects. This list may be generated using the getConvexObjects module.
% ImageLabel – Label matrix containing the original objects before segmentation.
% MinBlobArea – Objects resulting from segmentation that have an area smaller than this value will be unsegmented.
% WatershedLabel – Label matrix containing the objects after segmentation.
% Output Structure Members
% LabelMatrix – A label matrix containing the objects segmented according to the segmentation in WatershedLabel with the exception of convex objects, which are left unaltered.

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
		zero_idx = find(segmentation_idx == 0);
		for(k=1:size(zero_idx))
			if(zero_idx(k) == 1)
				segmentation_idx(zero_idx(k)) = ...
					segmentation_idx(zero_idx(k) + 1);
			else
				segmentation_idx(zero_idx(k)) = ...
					segmentation_idx(zero_idx(k) - 1);
			end
		end
        %the segmentation might create objects that are smaller than our
        %minimum object size - we need to unsegment those
        [valid_segmentation_ids valid_len new_segmentation_idx]=determineValidObjects(segmentation_idx,...
            min_nucl_area,blob_1,blob_2);
        if (valid_len<2)
            %splitting this blob results in objects that are all or all-but-one smaller
            %than our minimum object size - so no split
            continue;
        end
        if (~isempty(new_segmentation_idx))
            segmentation_idx=new_segmentation_idx;
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
