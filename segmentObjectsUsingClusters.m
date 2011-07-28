function output_args=segmentObjectsUsingClusters(input_args)
%Usage
%This module is used to segment objects in a label matrix using hierarchical clustering.
%
%Input Structure Members
%ClusterDistance – The height threshold for the cluster tree. All leaves below this value will be
%grouped in a cluster. See documentation for the MATLAB function cluster for more details.
%MinimumObjectArea – Objects with an area smaller than this value will be unsegmented and
%distributed between the neighboring objects.
%ObjectsLabel – The label matrix containing the objects to be segmented.
%ObjectReduce – Used to reduce the size of the objects. If the objects are too large the clustering
%function will run out of memory. When this happens set ObjectReduce to a value lower than
%one.
%
%Output Structure Members
%LabelMatrix – The label matrix containing the segmented objects.
%
%Example
%
%segment_objects_using_clusters_function.InstanceName='SegmentObjectsUsingClus
%ters';
%segment_objects_using_clusters_function.FunctionHandle=@segmentObjectsUsingCl
%usters;
%segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.FunctionIns
%tance='LabelNuclei';
%segment_objects_using_clusters_function.FunctionArgs.ObjectsLabel.OutputArg='
%LabelMatrix';
%segment_objects_using_clusters_function.FunctionArgs.ObjectReduce.Value=Track
%Struct.ObjectReduce;
%segment_objects_using_clusters_function.FunctionArgs.MinimumObjectArea.Value=
%TrackStruct.MinNuclArea;
%segment_objects_using_clusters_function.FunctionArgs.ClusterDistance.Value=Tr
%ackStruct.ClusterDist;
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,segmen
%t_objects_using_clusters_function);
%
%…
%
%segment_objects_using_markers_function.FunctionArgs.MarkersLabel.FunctionInst
%ance='SegmentObjectsUsingClusters';
%segment_objects_using_markers_function.FunctionArgs.MarkersLabel.OutputArg='L
%abelMatrix';

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
    nr_points=accumarray(segmentation_idx,1);
    centroid_1=accumarray(segmentation_idx,blob_1)./nr_points;
    centroid_2=accumarray(segmentation_idx,blob_2)./nr_points;
    invalid_ids_idx=(nr_points==0);
    centroid_1(invalid_ids_idx)=[];
    centroid_2(invalid_ids_idx)=[];
    training=[[centroid_1; centroid_1-1; centroid_1+1] [centroid_2; centroid_2-1; centroid_2+1]];
    groups=repmat(valid_segmentation_ids',3,1);
    segmentation_idx=classify([blob_1 blob_2],training,groups,'diaglinear');
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
