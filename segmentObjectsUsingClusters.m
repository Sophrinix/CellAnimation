function output_args=segmentObjectsUsingClusters(input_args)

cells_lbl=input_args.ObjectsLabel.Value;
%should only set obj_reduce to a value smaller than 1 if the
%getBlobClusters runs out of memory with it set to 1.
obj_reduce=input_args.ObjectReduce.Value;
cluster_dist=input_args.ClusterDistance.Value;
min_object_area=input_args.MinimumObjectArea.Value;
img_sz=size(cells_lbl);

obj_nr=max(cells_lbl(:));
% assign each unassigned pixel in a blob to the closest polygon
% showmaxfigure(1),imshow(img_to_proc_norm)
for i=1:obj_nr
    cur_obj=cells_lbl==i;
    if (obj_reduce<1)
        simple_obj=imresize(cur_obj, obj_reduce,'nearest');
    else
        simple_obj=cur_obj;
    end
    [blob_1 blob_2]=find(simple_obj);
    if (size(blob_1,1)<2)
        continue;
    end
    [nr_clusters linkage_clusters]=getBlobClusters([blob_1 blob_2],cluster_dist);
    if (nr_clusters==1)
        %the blob is one colony no need to modify cells_lbl
        continue;
    end
    
    if (obj_reduce<1)
        %bring the blob coord back to original size
        cluster_1=blob_1/obj_reduce;
        cluster_2=blob_2/obj_reduce;
        [blob_1 blob_2]=find(cur_obj);
        %use nearest neighbor to assign all the pixels in the blob to 
        %the clusters
        segmentation_idx=knnclassify([blob_1 blob_2],[cluster_1 cluster_2],linkage_clusters);
    else
        segmentation_idx=linkage_clusters;
    end
     %the segmentation might create objects that are smaller than our
     %minimum object size - we need to unsegment those
    [valid_segmentation_ids valid_len new_segmentation_idx]=determineValidObjects(segmentation_idx,...
        min_object_area,blob_1,blob_2);    
    if (valid_len<2)
        %splitting this blob results in objects that are all or all-but-one smaller
        %than our minimum object size - so no split
        continue;
    end
    if (~isempty(new_segmentation_idx))
        segmentation_idx=new_segmentation_idx;
    end
    nr_clusters=valid_len;
    cur_max=max(cells_lbl(:));
    for j=2:nr_clusters
        cur_idx=segmentation_idx==valid_segmentation_ids(j);
        cell_coord_1=blob_1(cur_idx);
        cell_coord_2=blob_2(cur_idx);
        cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
        cells_lbl(cell_coord_lin)=cur_max+j-1;
    end    
end

output_args.LabelMatrix=cells_lbl;
%end segmentObjectsUsingClusters
end