function connected_blob=connectBlobs(unconnected_blobs, nr_blobs)
%helper function to deal with fragmented blobs. get a bunch of unconnected blobs and connect them using shortest distance
%lines

unconnected_blobs=imfill(unconnected_blobs,'holes');
%get the perimeter of the blobs
blobs_perim=bwperim(unconnected_blobs);
blobs_perim_lbl=bwlabeln(blobs_perim);
[connected_blob_1 connected_blob_2]=find(blobs_perim_lbl==1);
for i=2:nr_blobs
    [cur_blob_1 cur_blob_2]=find(blobs_perim_lbl==i);
    min_dist=Inf;
    for j=1:size(cur_blob_1,1)
        dist_to_cur_blob=hypot(connected_blob_1-cur_blob_1(j),connected_blob_2-cur_blob_2(j));
        [cur_min_dist cur_min_dist_idx]=min(dist_to_cur_blob);
        if (cur_min_dist<min_dist)
            min_dist=cur_min_dist;
            cur_blob_min_dist_idx=j;
            connected_blob_min_dist_idx=cur_min_dist_idx;
        end
    end
    
    connected_blob_closest_point_1=connected_blob_1(connected_blob_min_dist_idx);
    connected_blob_closest_point_2=connected_blob_2(connected_blob_min_dist_idx);
    cur_blob_closest_point_1=cur_blob_1(cur_blob_min_dist_idx);
    cur_blob_closest_point_2=cur_blob_2(cur_blob_min_dist_idx);
    
    cur_point=[connected_blob_closest_point_1 connected_blob_closest_point_2];
    min_dist=round(min_dist);
    connecting_line=zeros(min_dist,2);
    %progressively fill in the shortest path between the two
    %blobs
    for j=1:min_dist
        diff_1=cur_point(1)-cur_blob_closest_point_1;
        if (diff_1<0)
            cur_point(1)=cur_point(1)+1;
        elseif (diff_1>0)
            cur_point(1)=cur_point(1)-1;
        end
        diff_2=cur_point(2)-cur_blob_closest_point_2;
        if (diff_2<0)
            cur_point(2)=cur_point(2)+1;
        elseif (diff_2>0)
            cur_point(2)=cur_point(2)-1;
        end
        %add the cur_point to the list of pixels in the line connecting the
        %current blob to the connected blob
        connecting_line(j,:)=cur_point;                
    end
    
    %add the connecting line and the current blob to the connected blob
    connected_blob_1=[connected_blob_1; connecting_line(:,1); cur_blob_1];
    connected_blob_2=[connected_blob_2; connecting_line(:,2); cur_blob_2];
end

connected_blob_lin=sub2ind(size(unconnected_blobs),connected_blob_1,connected_blob_2);
connected_blob=unconnected_blobs;
connected_blob(connected_blob_lin)=true;

%end connectBlobs
end