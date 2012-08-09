function output_args=refineSegmentation(input_args)
% Usage
% This module is used to retain only objects in a label matrix that are nearest to objects in another matrix.
% Input Structure Members
% CurrentLabel – The label matrix from which objects may be removed if they don’t have an object to which they are nearest in the PreviousLabel matrix.
% PreviousLabel – The objects in this label will determine the objects that will be retained in the current label.
% Output Structure Members
% LabelMatrix – The filtered label matrix.


prev_label=input_args.PreviousLabel.Value;
cur_label=input_args.CurrentLabel.Value;

if (isempty(prev_label))
    output_args.LabelMatrix=cur_label;
    return;
end

prev_centroids=getApproximateCentroids(prev_label);
cur_centroids=getApproximateCentroids(cur_label);
cur_triangulation=DelaunayTri(cur_centroids(:,1),cur_centroids(:,2));

%get the indexes of the nearest centroids in the current label to the
%remaining centroids in the previous label

%%%%%%%% Original is deprecated
%%%nearest_idx=dsearch(cur_centroids(:,1),cur_centroids(:,2),cur_triangulation,...
%%%    prev_centroids(:,1),prev_centroids(:,2));
nearest_idx=nearestNeighbor(cur_triangulation,prev_centroids(:,1),prev_centroids(:,2));
label_ids=unique(nearest_idx);
new_label=bwlabeln(ismember(cur_label,label_ids));
output_args.LabelMatrix=new_label;

%end refineSegmentation
end
