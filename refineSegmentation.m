function output_args=refineSegmentation(input_args)
%module to retain only objects close to objects existing in the previous
%label matrix
prev_label=input_args.PreviousLabel.Value;
cur_label=input_args.CurrentLabel.Value;

if (isempty(prev_label))
    output_args.LabelMatrix=cur_label;
    return;
end

prev_centroids=getApproximateCentroids(prev_label);
cur_centroids=getApproximateCentroids(cur_label);
cur_triangulation=delaunay(cur_centroids(:,1),cur_centroids(:,2));

%get the indexes of the nearest centroids in the current label to the
%remaining centroids in the previous label
nearest_idx=dsearch(cur_centroids(:,1),cur_centroids(:,2),cur_triangulation,...
    prev_centroids(:,1),prev_centroids(:,2));
label_ids=unique(nearest_idx);
new_label=bwlabeln(ismember(cur_label,label_ids));
output_args.LabelMatrix=new_label;

%end refineSegmentation
end