function output_args=getObjectsMeanDisplacement(input_args)
% Usage
% This module estimates the average displacement of the cells in the frame using the centroids from the previous and current frame.
% Input Structure Members
% Centroid1Col – The index of the first coordinate of the object centroids in the tracks matrix.
% Centroid2Col – The index of the second coordinate of the object centroids in the tracks matrix.
% CurrentTracks – Set of tracks belonging to previous frame.
% ObjectCentroids – The list of centroids in the current frame.
% Output Structure Members
% MeanDisplacement – The estimated mean displacement of the objects in the frame.
% SDDisplacement – The estimated standard deviation of the objects in the frame.

prev_frame_centroids=input_args.CurrentTracks.Value(:,input_args.Centroid1Col.Value:input_args.Centroid2Col.Value);
cur_frame_centroids=input_args.ObjectCentroids.Value;
delaunay_tri=delaunay(prev_frame_centroids(:,1),prev_frame_centroids(:,2));
nearest_neighbors_idx=dsearch(prev_frame_centroids(:,1),prev_frame_centroids(:,2),delaunay_tri,...
    cur_frame_centroids(:,1),cur_frame_centroids(:,2));
cell_displacements=hypot(cur_frame_centroids(:,1)-prev_frame_centroids(nearest_neighbors_idx,1),...
    cur_frame_centroids(:,2)-prev_frame_centroids(nearest_neighbors_idx,2));
output_args.MeanDisplacement=mean(cell_displacements);
output_args.SDDisplacement=std(cell_displacements);
output_args.SearchRadius=output_args.MeanDisplacement+10*output_args.SDDisplacement;

%end getObjectsMeanDisplacement
end
