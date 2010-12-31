function [new_cells_ids parent_ids merge_with_parent new_cells_centroids parent_cells_centroids]=getDaughterCells(all_tracks, cur_tracks, ...
    cur_tracks_ids, cur_time, max_dist, new_cells_ids, new_tracks_idx, min_track_frames, cell_areas, cells_lbl,...
    med_area)
%helper function. use a series of filters to determine potential daughter
%cells
new_tracks=cur_tracks(new_tracks_idx,:);
new_tracks_sz=size(new_tracks,1);
merge_with_parent=false(new_tracks_sz,1);
parent_ids=zeros(new_tracks_sz,1);
new_cells_centroids=zeros(new_tracks_sz,2);
parent_cells_centroids=zeros(new_tracks_sz,2);
cur_tracks_sz=size(cur_tracks,1);
cur_tracks_cent=cur_tracks(:,1:2);
for i=1:new_tracks_sz
    cur_centroid=new_tracks(i,1:2);
    cur_lbl_id=cells_lbl(round(cur_centroid(1)),round(cur_centroid(2)));
    cur_centroid_mat=repmat(cur_centroid,cur_tracks_sz,1);
    cur_centroid_dist=hypot(cur_centroid_mat(:,1)-cur_tracks_cent(:,1),cur_centroid_mat(:,2)-cur_tracks_cent(:,2));
    cur_centroid_dist_idx=(cur_centroid_dist<max_dist)&(cur_centroid_dist>0.1);
    cur_centroid_dist=cur_centroid_dist(cur_centroid_dist_idx);
    nearby_centroids=cur_tracks_cent(cur_centroid_dist_idx,:);
    if (isempty(cur_centroid_dist))        
        continue;
    end
    nearby_cell_ids=cur_tracks_ids(cur_centroid_dist_idx);
    %remove cells that are new from the list of nearby cells
    keep_cells_idx=~ismember(nearby_cell_ids,new_cells_ids);
    nearby_cell_ids=nearby_cell_ids(keep_cells_idx);
    cur_centroid_dist=cur_centroid_dist(keep_cells_idx);
    nearby_centroids=nearby_centroids(keep_cells_idx,:);
    if (isempty(nearby_cell_ids))
        continue;
    end    
%     daughter_track_idx=all_tracks(:,4)==new_cells_ids(i);
%     daughter_track_centroids=all_tracks(daughter_track_idx,1:2);
%     daughter_track_length=size(daughter_track_centroids,1);
    [cur_centroid_dist dist_sort_idx]=sort(cur_centroid_dist);
    nearby_cell_ids=nearby_cell_ids(dist_sort_idx);
    nearby_centroids=nearby_centroids(dist_sort_idx,:);
    nearby_cells_sz=size(nearby_cell_ids,1);
    shrink_ratio=2*ones(nearby_cells_sz,1);
    shrink_ratio2=2*ones(nearby_cells_sz,1);
    daughter_area=cell_areas{new_cells_ids(i)};
    %use only the last area recorded for this id
    daughter_area=daughter_area(end);
    for j=1:size(nearby_cell_ids,1)
        if (j==1)
            nearby_lbl_id=cells_lbl(round(nearby_centroids(1,1)),round(nearby_centroids(1,2)));
            if (nearby_lbl_id==cur_lbl_id)
                parent_ids(i)=nearby_cell_ids(j);
                merge_with_parent(i)=true;
                new_cells_centroids(i,:)=cur_centroid;
                parent_cells_centroids(i,:)=nearby_centroids(1,:);
                break;
            end                
        end
        parent_track_idx=(all_tracks(:,4)==nearby_cell_ids(j))&(all_tracks(:,3)<cur_time);
        parent_track_centroids=all_tracks(parent_track_idx,1:2);
        parent_track_length=size(parent_track_centroids,1);
        if (parent_track_length<min_track_frames)
            continue;
        end
        pot_parent_areas=cell_areas{nearby_cell_ids(j)};
        parent_areas_len=length(pot_parent_areas);
        if (parent_areas_len<2)
            continue;
        end
        %the previous parent area should not be smaller than 1.5 times its daughter
        %cells
        if (parent_areas_len>3)            
            prev_parent_area=pot_parent_areas(end-2);
        else
            prev_parent_area=pot_parent_areas(end-1);
        end
        cur_parent_area=pot_parent_areas(end);
        thresh_area=0.6*med_area;
        if ((cur_parent_area>thresh_area)||(daughter_area>thresh_area))
            %if either of the daughter cells is too big it's not a real
            %mitotic event
            continue;
        end
        if (((2*prev_parent_area)<(cur_parent_area+daughter_area))||(cur_parent_area>3*daughter_area)...
                ||(daughter_area>3*cur_parent_area))
            %not a true mitotic event just a new nucleus next to a
            %preexisting nucleus
            continue;
        end
%         if (parent_areas_len>3)
%             test_areas=pot_parent_areas(end-2:end);
%             shrink_ratio(j)=test_areas(3)/test_areas(2);
%             shrink_ratio2(j)=test_areas(2)/test_areas(1);
%         else
%             shrink_ratio(j)=pot_parent_areas(end)/pot_parent_areas(end-1);
%         end
%         parent_track_idx=(all_tracks(:,4)==nearby_cell_ids(j))&(all_tracks(:,3)>=cur_time);
%         parent_track_centroids=all_tracks(parent_track_idx,1:2);
%         parent_track_length=size(parent_track_centroids,1);
%         if (parent_track_length<min_track_time)
%             continue;
%         end
%         parent_idx=find(cells_ids==nearby_cell_ids(j),1);
%         parent_gen=cells_generations(parent_idx);
%         if (parent_gen>1)
%             %cells higher than first generations need to have been around
%             %at least for a little while before they split
%             prev_track_idx=find((all_tracks(:,4)==nearby_cell_ids(j))&(all_tracks(:,3)<cur_time));
%             if (length(prev_track_idx)<min_track_time)
%                 continue;
%             end
%         end
%             
%         min_track_length=min(daughter_track_length,parent_track_length);
%         p_d_centroid_dist=hypot(daughter_track_centroids(1:min_track_length,1)-...
%             parent_track_centroids(1:min_track_length,1), daughter_track_centroids(1:min_track_length,2)...
%             -parent_track_centroids(1:min_track_length,2));
%         max_centroid_dist=max(p_d_centroid_dist);
%         %cells separate after splitting-it's not just a multinucleated cell
% %         if (max_centroid_dist>1.2*max_dist)            
%             parent_ids(i)=nearby_cell_ids(j);
%             break;
% %         end
        parent_ids(i)=nearby_cell_ids(j);
        break;
    end
%     [parent_ratio parent_idx]=min(shrink_ratio);
%     if (parent_ratio>0.9)
%         [parent_ratio parent_idx]=min(shrink_ratio2);
%         if (parent_ratio>0.9)
%             continue;
%         end
%     end    
end

%end function
end