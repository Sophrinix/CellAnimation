function joined_blob=joinFragmentedBlob(fragmented_blob)
%helper function to join the parts of a fragmented blob 
joined_blob=fragmented_blob;
blob_boundaries=bwboundaries(fragmented_blob,8,'noholes');
nr_blobs=length(blob_boundaries);
%calculate the minimum sampling distance
%we want the crust algorithm to close edges around the disjointed blobs
%so the minimum sampling distance will be the max(min_distance) between the
%point sets
%determine the nearest blob to each individual blob
min_distances=ones(nr_blobs)*Inf;
intersets_edge_indexes=cell(nr_blobs);
min_distance_indexes=zeros(nr_blobs);
for i=1:(nr_blobs-1)
    for j=(i+1):nr_blobs
        if (i==j)
            continue;
        end
        [min_distance min_distance_index interset_edge_indexes]=getMinDistanceBetweenPointSets(blob_boundaries{i},blob_boundaries{j});
        min_distances(i,j)=min_distance;
        min_distance_indexes(i,j)=min_distance_index;
        intersets_edge_indexes{i,j}=interset_edge_indexes;
    end
end

[dummy nearest_blob_idx]=min(min_distances,[],2);

blob_sz=size(fragmented_blob);
for i=1:nr_blobs-1
    j=nearest_blob_idx(i);
    join_polygon=getJoinPolygon(blob_boundaries{i},...
        blob_boundaries{j}, intersets_edge_indexes{i,j}, min_distance_indexes(i,j));
    %create the image of the join
    img_join=poly2mask(join_polygon(2,:),join_polygon(1,:),blob_sz(1),blob_sz(2));
    %merge it with the blob image
    joined_blob=joined_blob|img_join;
end



%end joinFragmentedBlob
end

function join_polygon=getJoinPolygon(set_a, set_b, interset_edge_indexes, min_distance_index)
%get the coordinates of the polygon points from set a and set b that will form the join
%between the two boundaries
%put all the indexes from set a in one vector and all vectors from set b in
%another. the indexes for set b are offset by the size of set a.
set_a_sz=size(set_a,1);
temp_indexes=interset_edge_indexes;
set_b_indexes_idx=interset_edge_indexes>set_a_sz;
temp_indexes(set_b_indexes_idx)=0;
set_a_indexes=temp_indexes(:,1)+temp_indexes(:,2);
temp_indexes=interset_edge_indexes;
temp_indexes(~set_b_indexes_idx)=0;
set_b_indexes=temp_indexes(:,1)+temp_indexes(:,2);
%remove the set_b indexes offset
set_b_indexes=set_b_indexes-set_a_sz;
%get the min distance points
point_a=set_a(set_a_indexes(min_distance_index),:);
point_b=set_b(set_b_indexes(min_distance_index),:);
%caculate the orientation of the minimum distance line
min_distance_angle=atan2(point_a(:,2)-point_b(:,2),point_a(:,1)-point_b(:,1));
%calculate the orientation of all the inter-set lines
edge_angles=atan2(set_a(set_a_indexes,2)-set_b(set_b_indexes,2),set_a(set_a_indexes,1)-set_b(set_b_indexes,1));
%get all the edges that have the same orientation
same_orientation_idx=(edge_angles==min_distance_angle);
new_min_distance_index=find(same_orientation_idx)==min_distance_index;
%select edges of the same orientation with the min
%distance line as this is where the join will be made
set_a_select_edges=set_a_indexes(same_orientation_idx);
set_b_select_edges=set_b_indexes(same_orientation_idx);
set_a_selected_points=set_a(set_a_select_edges,:);
set_b_selected_points=set_b(set_b_select_edges,:);
if (size(set_a_selected_points,1)==1)
    point_a=set_a_selected_points';
    point_b=set_b_selected_points';
    line_slope=(point_a(1)-point_b(1))/(point_a(2)-point_b(2));
    if (line_slope>0)
        line_offset=[2;-2];
    else
        line_offset=[2;2];
    end
    join_polygon=[point_a+line_offset point_b+line_offset point_b-line_offset point_a-line_offset point_a+line_offset];
    return;
end
a_clusters=getPointsClusters(set_a_selected_points);
b_clusters=getPointsClusters(set_b_selected_points);
%find out which clusters contains the min distance points
min_distance_a_cluster_idx=a_clusters(new_min_distance_index);
min_distance_b_cluster_idx=b_clusters(new_min_distance_index);
edges_to_keep_idx=(a_clusters==min_distance_a_cluster_idx)&(b_clusters==min_distance_b_cluster_idx);
set_a_select_edges=set_a_select_edges(edges_to_keep_idx);
set_b_select_edges=set_b_select_edges(edges_to_keep_idx);
%get the min and max points
%xmin
[set_a_x_min set_a_x_min_idx]=min(set_a(set_a_select_edges,1));
[set_b_x_min set_b_x_min_idx]=min(set_b(set_b_select_edges,1));
if (set_a_x_min<set_b_x_min)
    x_min_idx=set_a_x_min_idx;    
else
    x_min_idx=set_b_x_min_idx;
end
x_min_edge_indexes=[set_a_select_edges(x_min_idx) set_b_select_edges(x_min_idx)];
edge_1_points=[set_a(x_min_edge_indexes(1),:)' set_b(x_min_edge_indexes(2),:)'];
b_found_edges=false;
%xmax
[set_a_x_max set_a_x_max_idx]=max(set_a(set_a_select_edges,1));
[set_b_x_max set_b_x_max_idx]=max(set_b(set_b_select_edges,1));
if (set_a_x_max>set_b_x_max)
    x_max_idx=set_a_x_max_idx;    
else
    x_max_idx=set_b_x_max_idx;
end
x_max_edge_indexes=[set_a_select_edges(x_max_idx) set_b_select_edges(x_max_idx)];
edge_points=[set_a(x_max_edge_indexes(1),:)' set_b(x_max_edge_indexes(2),:)'];
if (sum(edge_1_points-edge_points))
    b_found_edges=true;
    edge_2_points=edge_points;
end

%ymin
if (~b_found_edges)
    [set_a_y_min set_a_y_min_idx]=min(set_a(set_a_select_edges,2));
    [set_b_y_min set_b_y_min_idx]=min(set_b(set_b_select_edges,2));
    if (set_a_y_min<set_b_y_min)
        y_min_idx=set_a_y_min_idx;
    else
        y_min_idx=set_b_y_min_idx;
    end
    y_min_edge_indexes=[set_a_select_edges(y_min_idx) set_b_select_edges(y_min_idx)];
    edge_points=[set_a(y_min_edge_indexes(1),:)' set_b(y_min_edge_indexes(2),:)'];
    if (sum(edge_1_points-edge_points))
        b_found_edges=true;
        edge_2_points=edge_points;
    end
end

%ymax
if (~b_found_edges)
    [set_a_y_max set_a_y_max_idx]=max(set_a(set_a_select_edges,2));
    [set_b_y_max set_b_y_max_idx]=max(set_b(set_b_select_edges,2));
    if (set_a_y_max<set_b_y_max)
        y_max_idx=set_a_y_max_idx;
    else
        y_max_idx=set_b_y_max_idx;
    end
    if (sum(edge_1_points-edge_points))
        b_found_edges=true;
        y_max_edge_indexes=[set_a_select_edges(y_max_idx) set_b_select_edges(y_max_idx)];
        edge_points=[set_a(y_max_edge_indexes(1),:)' set_b(y_max_edge_indexes(2),:)'];
        edge_2_points=edge_points;
    else
        %connection is only a line
        edge_2_points=edge_1_points;
    end
    
end
if (b_found_edges)
    join_polygon=[edge_1_points edge_2_points(:,2) edge_2_points(:,1) edge_1_points(:,1)];
    %need to subtract and add half a pixel or polymask will not included the
    %edge of the polygon
    x_lower_half_idx=join_polygon(1,:)<median(join_polygon(1,1:(end-1)));
    join_polygon(1,x_lower_half_idx)=join_polygon(1,x_lower_half_idx)-1;
    join_polygon(1,~x_lower_half_idx)=join_polygon(1,~x_lower_half_idx)+1;
    y_lower_half_idx=join_polygon(2,:)<median(join_polygon(2,1:(end-1)));
    join_polygon(2,y_lower_half_idx)=join_polygon(2,y_lower_half_idx)-1;
    join_polygon(2,~y_lower_half_idx)=join_polygon(2,~y_lower_half_idx)+1;
else
    %connection is only a line so we'll make a very narrow polygon
    %offset two pixels on each side of the line
    point_a=edge_1_points(:,1);
    point_b=edge_1_points(:,2);
    line_slope=(point_a(1)-point_b(1))/(point_a(2)-point_b(2));
    if (line_slope>0)
        line_offset=[2;-2];        
    else
        line_offset=[2;2];        
    end
    join_polygon=[point_a+line_offset point_b+line_offset point_b-line_offset point_a-line_offset point_a+line_offset];
end

%end preparePointSetPairsForJoin
end

function linkage_clusters=getPointsClusters(point_set)
%test and make sure the point sets are not equal
set_sz=size(point_set);
test_set=repmat(point_set(1,:),set_sz(1),1);
if isequal(point_set,test_set)
    linkage_clusters=ones(set_sz(1),1);
    return;
end
blob_dist=pdist(point_set);
%tested all linkage params - this works best
blob_linkage=linkage(blob_dist,'average');
linkage_clusters=cluster(blob_linkage,'criterion','distance','cutoff',5);

%end getPointsClusters
end