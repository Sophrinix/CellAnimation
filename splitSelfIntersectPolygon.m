function pols_split=splitSelfIntersectPolygon(pol_original)
%original polygon length
pol_len=size(pol_original,1);

if (pol_len<4)
    pols_split{1}=pol_original;
    return;
end    
[intersect_points_1 intersect_points_2 intersect_segments]=selfintersect(pol_original(:,1),pol_original(:,2));
%number of self-intersecting points
intersect_points_nr=size(intersect_points_1,1);
%need to write my own selfintersect algorithm. selfintersect is awful at
%handling self intersecting vertices. for now remove all self intersect
%vertices and add the true self-intersecting ones myself
pol_eps=0.0001;
remove_mask=false(intersect_points_nr,1);
for i=1:intersect_points_nr
    points_are_vertices_idx=(abs(intersect_points_1(i)-pol_original(:,1))<pol_eps)&...
        (abs(intersect_points_2(i)-pol_original(:,2))<pol_eps);
    if (max(points_are_vertices_idx)==1)
        remove_mask(i)=true;        
    end    
end

intersect_points_1(remove_mask)=[];
intersect_points_2(remove_mask)=[];
intersect_segments(remove_mask,:)=[];

if isempty(intersect_points_1)
    %add back true self-intersecting vertices
    for i=1:pol_len-1                
        self_intersect_idx=...
            find((pol_original(i+1:end-1,1)==pol_original(i,1))&(pol_original(i+1:end-1,2)==pol_original(i,2)));
        if (~isempty(self_intersect_idx))
            intersect_len=length(self_intersect_idx);
            intersect_points_1=[intersect_points_1; pol_original(i,1)*ones(intersect_len,1)];
            intersect_points_2=[intersect_points_2; pol_original(i,2)*ones(intersect_len,1)];            
            intersect_segments=[intersect_segments;[i*ones(intersect_len,1) self_intersect_idx+i]];                     
        end        
    end
    if isempty(intersect_points_1)
        pols_split{1}=pol_original;
        return;
    end
end


%number of self-intersecting points
intersect_points_nr=size(intersect_points_1,1);
%self intersect algo is buggy and returns points that are not on any
%segment of the polygon as self intersect points - check for that and
%remove
remove_mask=true(intersect_points_nr,1);
for i=1:intersect_points_nr
    bFoundPoint=false;
    test_point=[intersect_points_1(i) intersect_points_2(i)];
    for j=1:pol_len-1
        min_coords=min(pol_original(j:j+1,:));
        max_coords=max(pol_original(j:j+1,:));
        if ((test_point(1,1)>=min_coords(1,1))&&(test_point(1,1)<=max_coords(1,1))&&...
                (test_point(1,2)>=min_coords(1,2))&&(test_point(1,2)<=max_coords(1,2)))
            if (rank([pol_original(j,:)-test_point; pol_original(j+1,:)-test_point],pol_eps)<2)
                %the start point is colinear with this segment - point is
                %valid
                remove_mask(i)=false;
                break;
            end
        end
    end    
end

intersect_points_1(remove_mask)=[];
if isempty(intersect_points_1)
    pols_split{1}=pol_original;
    return;
end
intersect_points_2(remove_mask)=[];
intersect_segments(remove_mask,:)=[];

%update number of self-intersecting points
intersect_points_nr=size(intersect_points_1,1);


%new number of indices - each self-intersect point has two indices
indices_nr=pol_len+2*intersect_points_nr;
%figure out if there are segments containing more than one
%self-intersection point
[intersect_segments_sort_1 sort_1_idx]=sort(intersect_segments(:,1));
[intersect_segments_sort_2 sort_2_idx]=sort(intersect_segments(:,2));
if (intersect_points_nr>1)
    intersect_segments_diff_1=diff(intersect_segments_sort_1);
    %intersect_segments_eq will == 0 where the elements are equal
    intersect_segments_eq_1=[1 ;intersect_segments_diff_1]&[intersect_segments_diff_1; 1];
%     intersect_segments_eq_1=logical(intersect_segments_eq_1);
%     if (min(intersect_segments_eq_1)==0)
        %need to calculate the distance to each intersection point will use
        %it to assign indexes to points on the same segment
        distance1=hypot(pol_original(intersect_segments_sort_1,1)-intersect_points_1,...
            pol_original(intersect_segments_sort_1,2)-intersect_points_2);
%     end
    intersect_segments_diff_2=diff(intersect_segments_sort_2);
    %intersect_segments_eq will == 0 where the elements are equal
    intersect_segments_eq_2=[1;intersect_segments_diff_2]&[intersect_segments_diff_2;1];
%     intersect_segments_eq_2=logical(intersect_segments_eq_2);
%     if (min(intersect_segments_eq_2)==0)
         %need to calculate the distance to each intersection point will use
        %it to assign indexes to points on the same segment
        distance2=hypot(pol_original(intersect_segments_sort_2,1)-intersect_points_1,...
            pol_original(intersect_segments_sort_2,2)-intersect_points_2);        
%     end
end
first_index=zeros(intersect_points_nr,1);
second_index=zeros(intersect_points_nr,1);
%calculate the two index values for each self-intersection point
bSameSegment=false;
if (intersect_points_nr>1)
    for i=1:intersect_points_nr
        second_indexes_to_add_idx=find(intersect_segments_sort_1(i)>intersect_segments_sort_2);
        if (isempty(second_indexes_to_add_idx))
            second_indexes_to_add=0;
        else
            second_indexes_to_add=length(second_indexes_to_add_idx)+1;
        end
        equal_indexes_idx=find(intersect_segments_sort_1(i)==intersect_segments_sort_2);
        if (~isempty(equal_indexes_idx))
            %determine whether i need to increase this vertex's index
            %based on the position of the other intersection points with which it shares its segment
            points_on_same_seg_dist=distance1(i);
            points_on_same_seg_dist=[points_on_same_seg_dist; distance2(equal_indexes_idx)];
            [dummy point_on_same_seg_idx]=sort(points_on_same_seg_dist);
            second_indexes_to_add=second_indexes_to_add+point_on_same_seg_idx(1)-1;
        end
        if (i<intersect_points_nr)
            if (intersect_segments_sort_1(i)==intersect_segments_sort_1(i+1))
                if (~bSameSegment)
                    bSameSegment=true;
                    start_seg_idx=i;
                    end_seg_idx=find(intersect_segments_sort_1((i+1):end)~=intersect_segments_sort_1(i),1);
                    if (isempty(end_seg_idx))
                        end_seg_idx=intersect_points_nr;
                    else
                        end_seg_idx=i+end_seg_idx-1;
                    end
                    [dummy distance_sort]=sort(distance1(start_seg_idx:end_seg_idx));
                    %if we have multiple intersection points on the same segment
                    %points which are closer to the start of the segment get lower
                    %indices
                    first_index(i)=intersect_segments(i,1)+i+distance_sort(1)-1+second_indexes_to_add;
                else
                    first_index(i)=intersect_segments_sort_1(i)+start_seg_idx+distance_sort(i-start_seg_idx+1)-1+...
                        second_indexes_to_add;
                end
            else
                if (bSameSegment)
                    first_index(i)=intersect_segments_sort_1(i)+start_seg_idx+distance_sort(i-start_seg_idx+1)-1+...
                        second_indexes_to_add;
                else                
                    first_index(i)=intersect_segments_sort_1(i)+i+second_indexes_to_add;
                end
                bSameSegment=false;
            end
        else
            if (intersect_segments_sort_1(i-1)==intersect_segments_sort_1(i))                
                first_index(i)=intersect_segments_sort_1(i)+start_seg_idx+distance_sort(i-start_seg_idx+1)-1+second_indexes_to_add;
            else                
                first_index(i)=intersect_segments_sort_1(i)+i+second_indexes_to_add;
            end
        end
    end
else
    first_index=intersect_segments_sort_1(1)+1;
end

bSameSegment=false;
if (intersect_points_nr>1)
    for i=1:intersect_points_nr
        %find indexes in first index we are past
        first_indexes_to_add_idx=find(intersect_segments_sort_2(i)>intersect_segments_sort_1);
        if (isempty(first_indexes_to_add_idx))
            first_indexes_to_add=0;
        else
            first_indexes_to_add=length(first_indexes_to_add_idx);
        end
        equal_indexes_idx=find(intersect_segments_sort_2(i)==intersect_segments_sort_1);
        if (~isempty(equal_indexes_idx))
            %determine whether i need to increase this vertex's index
            %based on the position of the other intersection points with which it shares its segment
            points_on_same_seg_dist=distance2(i);
            points_on_same_seg_dist=[points_on_same_seg_dist; distance1(equal_indexes_idx)];
            [dummy point_on_same_seg_idx]=sort(points_on_same_seg_dist);
            first_indexes_to_add=first_indexes_to_add+point_on_same_seg_idx(1)-1;
        end
        second_indexes_to_add_idx=find(intersect_segments_sort_2(i)>intersect_segments_sort_2);
        if (isempty(second_indexes_to_add_idx))
            second_indexes_to_add=1;
        else
            second_indexes_to_add=length(second_indexes_to_add_idx)+1;
        end
        if(i<intersect_points_nr)
            if (intersect_segments_sort_2(i)==intersect_segments_sort_2(i+1))
                if (~bSameSegment)
                    bSameSegment=true;
                    start_seg_idx=i;
                    start_seg_add=second_indexes_to_add;
                    end_seg_idx=find(intersect_segments_sort_2((i+1):end)~=intersect_segments_sort_2(i),1);
                    if (isempty(end_seg_idx))
                        end_seg_idx=intersect_points_nr;
                    else
                        end_seg_idx=i+end_seg_idx-1;
                    end
                    [dummy distance_sort]=sort(distance2(start_seg_idx:end_seg_idx));
                    %if we have multiple intersection points on the same segment
                    %points which are closer to the start of the segment get lower
                    %indices - first_indexes_to_add because for each point in the second index
                    %there's a point in the first index that's lower
                    second_index(i)=intersect_segments_sort_2(i)+second_indexes_to_add+distance_sort(1)-1+first_indexes_to_add;
                else
                    second_index(i)=intersect_segments_sort_2(i)+start_seg_add+distance_sort(i-start_seg_idx+1)-1+first_indexes_to_add;
                end
            else
                if (bSameSegment)
                    second_index(i)=intersect_segments_sort_2(i)+start_seg_add+distance_sort(i-start_seg_idx+1)-1+first_indexes_to_add;
                else
                    second_index(i)=intersect_segments_sort_2(i)+second_indexes_to_add+first_indexes_to_add;
                end
                bSameSegment=false;                
            end
        else
            if (intersect_segments_sort_2(i-1)==intersect_segments_sort_2(i))                
                second_index(i)=intersect_segments_sort_2(i)+start_seg_add+distance_sort(i-start_seg_idx+1)-1+first_indexes_to_add;
            else                
                second_index(i)=intersect_segments_sort_2(i)+second_indexes_to_add+first_indexes_to_add;
            end
        end
    end
else
    second_index=intersect_segments_sort_2(1)+2;
end
%resynch the indexes to each other
[dummy unsort_1]=sort(sort_1_idx);
first_index=first_index(unsort_1);
[dummy unsort_2]=sort(sort_2_idx);
second_index=second_index(unsort_2);

%generate a new self-intersecting polygon which lists the self-intersecting
%points at the appropriate locations
pol_complete=zeros(indices_nr,2);
pol_complete(first_index,1)=intersect_points_1;
pol_complete(first_index,2)=intersect_points_2;
pol_complete(second_index,1)=intersect_points_1;
pol_complete(second_index,2)=intersect_points_2;
%create a logical index for the original points
orig_idx=true(indices_nr,1);
orig_idx(first_index)=false;
orig_idx(second_index)=false;
pol_complete(orig_idx,:)=pol_original;

%split the original polygon into multiple distinct polygons
pols_split=cell(intersect_points_nr+1,1);
%first index has to be sorted
[first_index_sorted first_index_sorted_idx]=sort(first_index);
first_index=first_index_sorted;
second_index=second_index(first_index_sorted_idx);
intersect_segments=intersect_segments(first_index_sorted_idx,:);

%build the first polygon outside the loop since it's different from all the rest
pols_split{1}=[pol_complete(1:first_index(1),:); pol_complete((second_index(1)+1):end,:)];

for i=1:intersect_points_nr
    %build up the polygon by making up segments of consecutive points. each
    %time a s.i.p. is reached switch from first_index to second_index and viceversa - this
    %allows closing of individual polygons    
    pol_build=[];
    end_segment_idx=-1;
    start_segment_idx=first_index(i);
    cur_index=first_index;
    other_index=second_index;
    while (end_segment_idx~=second_index(i))
        end_idx=find((cur_index>start_segment_idx)&(cur_index<second_index(i)),1);
        end_segment_idx=cur_index(end_idx);        
        if (isempty(end_segment_idx))
            end_segment_idx=second_index(i);
            pol_build=[pol_build;pol_complete(start_segment_idx:end_segment_idx,:)];
        else
            pol_build=[pol_build;pol_complete(start_segment_idx:end_segment_idx-1,:)];
        end       
        temp_index=cur_index;
        cur_index=other_index;        
        other_index=cur_index;
        %update our start index since we're switching indexing arrays
        start_segment_idx=cur_index(end_idx);
    end
    pols_split{i+1}=pol_build;
end