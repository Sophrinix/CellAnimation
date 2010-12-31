function output_args=segmentObjectsUsingMarkers(input_args)
%module to segment objects in a binary image using nuclear markers
nuclei_lbl=input_args.MarkersLabel.Value;
cyto_lbl=input_args.ObjectsLabel.Value;
img_sz=size(nuclei_lbl);

nuclei_nr=max(nuclei_lbl(:));
nuclei_centroids_1=zeros(nuclei_nr,1);
nuclei_centroids_2=zeros(nuclei_nr,1);
for i=1:nuclei_nr
    [cur_obj_1 cur_obj_2]=find(nuclei_lbl==i);
    obj_length=length(cur_obj_1);
    nuclei_centroids_1(i)=sum(cur_obj_1)./obj_length;
    nuclei_centroids_2(i)=sum(cur_obj_2)./obj_length;
end
nuclei_centroids_lin=sub2ind(img_sz,round(nuclei_centroids_1),round(nuclei_centroids_2));
cyto_idx=cyto_lbl(nuclei_centroids_lin);

cells_nr=max(cyto_lbl(:));
for i=1:cells_nr    
    cluster_ids=find(cyto_idx==i);
    nr_clusters=length(cluster_ids);
    if (nr_clusters<2)
        continue;
    end
    %this is assuming the centroids are synched with the nuclei label ids
    training_idx=ismember(nuclei_lbl,cluster_ids);
    [blob_1 blob_2]=find(cyto_lbl==i);
    [training_1 training_2]=find(training_idx);
    training_group=nuclei_lbl(training_idx);
    %we'll use only every fifth point as a training point or we will
    %run out of memory    
    k_idx=knnclassify([blob_1 blob_2],[training_1(1:5:end) training_2(1:5:end)],training_group(1:5:end));    
    cur_max=max(cyto_lbl(:));
    for j=2:nr_clusters
        cell_coord_1=blob_1(k_idx==cluster_ids(j));
        cell_coord_2=blob_2(k_idx==cluster_ids(j));
        cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
        cyto_lbl(cell_coord_lin)=cur_max+j-1;
    end
end
output_args.LabelMatrix=cyto_lbl;

%end segmentObjectsUsingMarkers
end