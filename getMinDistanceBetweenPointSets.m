function [min_distance min_distance_index interset_edge_indexes interset_edges_length]=getMinDistanceBetweenPointSets(set_a,set_b)
%get the smallest distance between two non-overlapping sets of points

points_cloud=[set_a;set_b];
set_a_sz=size(set_a,1);
delaunay_tri=delaunay(points_cloud(:,1),points_cloud(:,2));
delaunay_edge_indexes=[delaunay_tri(:,1:2);delaunay_tri(:,2:3); [delaunay_tri(:,3) delaunay_tri(:,1)]];
%keep only the edges between the two sets and get rid of those within the two sets
delaunay_edge_indexes((delaunay_edge_indexes(:,1)<=set_a_sz)&(delaunay_edge_indexes(:,2)<=set_a_sz),:)=[];
delaunay_edge_indexes((delaunay_edge_indexes(:,1)>set_a_sz)&(delaunay_edge_indexes(:,2)>set_a_sz),:)=[];
%calculate the inter-set distances
first_edge_points=points_cloud(delaunay_edge_indexes(:,1),:);
second_edge_points=points_cloud(delaunay_edge_indexes(:,2),:);
interset_edges_length=hypot(first_edge_points(:,1)-second_edge_points(:,1),first_edge_points(:,2)-second_edge_points(:,2));
interset_edge_indexes=delaunay_edge_indexes;
[min_distance min_distance_index]=min(interset_edges_length);

%end getMinDistanceBetweenPointSets
end