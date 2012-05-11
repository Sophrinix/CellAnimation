function output_args=segmentCytoUsingNuclei(input_args)
%segments cytoplasm binary image using data from nuclear label matrix
img_cyto=input_args.CytoImage.Value;
nucl_lbl=input_args.NuclearLabel.Value;

%do preliminary segmentation of cytoplasm
cyto_lbl=bwlabeln(img_cyto);
new_lbl=zeros(size(cyto_lbl));
%segmenting the clusters into individual cells


%get the nuclei ids present in the cluster
nr_clusters=max(cyto_lbl(:));
for i=1:nr_clusters
    cur_cluster=(cyto_lbl==i);
    %get the nuclei ids present in the cluster
    nucl_ids=nucl_lbl(cur_cluster);   
    nucl_ids=unique(nucl_ids);
    %remove the background id
    nucl_ids(nucl_ids==0)=[];
    if isempty(nucl_ids)
        %don't add objects without nuclei
        continue;
    end
    if (length(nucl_ids)==1)
        %only one nucleus - assign the entire cluster to that id
        new_lbl(cur_cluster)=nucl_ids;
        continue;
    end
    %get an index to only the nuclei
    nucl_idx=ismember(nucl_lbl,nucl_ids);
    %get the x-y coordinates
    [nucl_x nucl_y]=find(nucl_idx);
    [cluster_x cluster_y]=find(cur_cluster);
    group_data=nucl_lbl(nucl_idx);
    %classify each pixel in the cluster
    ss=200;
    pixel_class=knnclassify([cluster_x cluster_y],[nucl_x(1:ss:end) nucl_y(1:ss:end)],group_data(1:ss:end));
    new_lbl(cur_cluster)=pixel_class;
end

output_args.LabelMatrix=makeContinuousLabelMatrix(new_lbl);

%end segmentCytoUsingNuclei
end