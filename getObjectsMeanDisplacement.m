function output_args=getObjectsMeanDisplacement(input_args)

%this function makes the assumption that most of these objects can be
%located in the next frame using the shortest distance criteria
%compute the delaunay triangulation
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
