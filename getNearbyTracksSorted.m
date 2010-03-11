function [nearby_tracks_sorted group_idx matching_groups]=getNearbyTracksSorted(cur_id,cells_centroids,shape_params,tracks_layout...
    ,cur_tracks,prev_tracks,search_radius_pct,matching_groups,params_coeff_var,relevant_params_idx,matching_group_stats,...
    params_for_sure_match,param_weights,unknown_param_weights,distance_ranking_order,direction_ranking_order,unknown_ranking_order,...
    min_second_distance,max_dist_ratio,max_angle_diff)
%get the tracks in the local nhood of this cell sorted by matching scores
hugeNbr=1e6;
cur_cell_centroid=cells_centroids(cur_id,:);
areaCol=tracks_layout.AreaCol;
solCol=tracks_layout.SolCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
min_reliable_params=params_for_sure_match;
group_idx=0;

cur_shape_params=shape_params(cur_id,:);
dist_to_tracks=hypot(cur_tracks(:,centroid1Col)-cur_cell_centroid(1),...
    cur_tracks(:,centroid2Col)-cur_cell_centroid(2));
dist_to_tracks_sorted=sort(dist_to_tracks);
nearest_distance=dist_to_tracks_sorted(1);
search_radius=search_radius_pct*nearest_distance;
nearby_tracks_idx=(dist_to_tracks<search_radius);
%keep only tracks in the current search nhood
dist_to_tracks=dist_to_tracks(nearby_tracks_idx);
nearby_tracks=cur_tracks(nearby_tracks_idx,:);
if (isempty(nearby_tracks))
    nearby_tracks_sorted=[];
else
    %rank the tracks by how close their features are to the features of the
    %current cell
    %try to get previous cell travel direction if possible
    if (~isempty(prev_tracks))
        prev_nearby_tracks_idx=ismember(prev_tracks(:,trackIDCol),nearby_tracks(:,trackIDCol));
        prev_nearby_tracks=prev_tracks(prev_nearby_tracks_idx,:);
        if isempty(prev_nearby_tracks)
            prev_tracks_centroids=[];
        else
            nr_prev_tracks=size(prev_nearby_tracks,1);
            nr_cur_tracks=size(nearby_tracks,1);
            prev_tracks_centroids=zeros(nr_cur_tracks,2);
            if (nr_prev_tracks==nr_cur_tracks)
                preexisting_tracks_idx=true(nr_cur_tracks,1);
            else
                preexisting_tracks_idx=ismember(nearby_tracks(:,trackIDCol),prev_nearby_tracks(:,trackIDCol));
            end
            preexisting_tracks=nearby_tracks(preexisting_tracks_idx,:);
            %match order of tracks
            [dummy sort_cur_tracks_idx]=sort(preexisting_tracks(:,trackIDCol));
            [dummy sort_prev_tracks_idx]=sort(prev_nearby_tracks(:,trackIDCol));
            match_tracks_idx=sort_prev_tracks_idx(sort_cur_tracks_idx);
            prev_nearby_tracks=prev_nearby_tracks(match_tracks_idx,:);
            prev_nearby_tracks_centroids=prev_nearby_tracks(:,centroid1Col:centroid2Col);
            cur_nearby_tracks_centroids=preexisting_tracks(:,centroid1Col:centroid2Col);
            prev_tracks_centroids(preexisting_tracks_idx,:)=prev_nearby_tracks_centroids;            
        end
    else
        prev_tracks_centroids=[];
    end
    
    if isempty(prev_tracks_centroids)
        b_use_direction=false;
        %i'm assuming areaCol is the first param column and solCol the last
        cell_ranking_params=[min(dist_to_tracks) cur_shape_params(:,1:(solCol-areaCol+1))];
        tracks_ranking_params=[dist_to_tracks nearby_tracks(:,areaCol:solCol)];
        %sort the tracks by ranking tracks in pairs to the cell instead of
        %all tracks at once. this prevents false best matching tracks.
        tracks_ranks=rankParams(cell_ranking_params,tracks_ranking_params);
        ranking_order=getRankingOrder(cell_ranking_params,tracks_ranking_params,tracks_ranks,...
            matching_groups,tracks_layout,b_use_direction,matching_group_stats,min_second_distance,max_dist_ratio,max_angle_diff,...
            unknown_ranking_order,distance_ranking_order,direction_ranking_order);        
        group_idx=0;
        [tracks_params_sorted sort_idx]=sortManyToOneUsingPairs(cell_ranking_params,tracks_ranking_params,...
            b_use_direction,unknown_param_weights,param_weights,ranking_order,group_idx,relevant_params_idx);
        %rank the best and second best matching track        
    else
        b_use_direction=true;
        prev_tracks_directions=atan2(abs(cur_nearby_tracks_centroids(:,2)-prev_nearby_tracks_centroids(:,2)),...
            abs(cur_nearby_tracks_centroids(:,1)-prev_nearby_tracks_centroids(:,1)));
        cur_possible_track_directions=atan2(abs(cur_cell_centroid(2)-cur_nearby_tracks_centroids(:,2)),...
            abs(cur_cell_centroid(1)-cur_nearby_tracks_centroids(:,1)));
        directions_diff=zeros(nr_cur_tracks,1);
        directions_diff(preexisting_tracks_idx)=abs(cur_possible_track_directions-prev_tracks_directions);
        directions_diff(~preexisting_tracks_idx)=hugeNbr;
        %i'm assuming areaCol is the first param column and solCol the last
        cell_ranking_params=[min(dist_to_tracks) 0 cur_shape_params(:,1:(solCol-areaCol+1))];
        tracks_ranking_params=[dist_to_tracks directions_diff nearby_tracks(:,areaCol:solCol)];
        tracks_ranks=rankParams(cell_ranking_params,tracks_ranking_params);
        [ranking_order group_idx]=getRankingOrder(cell_ranking_params,tracks_ranking_params,tracks_ranks...
            ,matching_groups,tracks_layout,b_use_direction,matching_group_stats,min_second_distance,max_dist_ratio,max_angle_diff,...
            unknown_ranking_order,distance_ranking_order,direction_ranking_order);
        %sort the tracks by ranking tracks in pairs to the cell instead of
        %all tracks at once. this prevents false best matching tracks.
        [tracks_params_sorted sort_idx]=sortManyToOneUsingPairs(cell_ranking_params,tracks_ranking_params,...
            b_use_direction,unknown_param_weights,param_weights,ranking_order,group_idx,relevant_params_idx);
        %figure out if we have a track that is a sure match to the cell
        if (length(sort_idx)==1)
            b_sure_match=true;
            pair_ranks=rankParams(cell_ranking_params,tracks_params_sorted);
        else
            %rank the best and second best matching track
            pair_ranks=rankParams(cell_ranking_params,tracks_params_sorted(1:2,:));            
            nr_best_match_params=sum(pair_ranks(1,:)==1);
            if (nr_best_match_params>=params_for_sure_match)
                b_sure_match=true;
            else
                b_sure_match=false;
            end
        end
        if (b_sure_match)
            %this track is a sure match-we'll use it to figure out which
            %parameters work best to assign other cells
            if (length(sort_idx)==1)
                [dummy matching_groups group_idx]=addToMatchingGroups(matching_groups,cell_ranking_params,...
                    tracks_params_sorted,params_coeff_var,1,min_reliable_params,pair_ranks,...
                    relevant_params_idx,max_angle_diff,min_second_distance,max_dist_ratio);
            else
                [dummy matching_groups group_idx]=addToMatchingGroups(matching_groups,cell_ranking_params,...
                    tracks_params_sorted(1:2,:),params_coeff_var,1,min_reliable_params,pair_ranks,...
                    relevant_params_idx,max_angle_diff,min_second_distance,max_dist_ratio);
            end
        else
            if (length(sort_idx)==1)
                [dummy group_idx]=getRankingOrder(cell_ranking_params,tracks_params_sorted,pair_ranks,...
                    matching_groups,tracks_layout,true,matching_group_stats,min_second_distance,max_dist_ratio,max_angle_diff,...
                    unknown_ranking_order,distance_ranking_order,direction_ranking_order);
            else
                    [dummy group_idx]=getRankingOrder(cell_ranking_params,tracks_params_sorted(1:2,:),pair_ranks,...
                    matching_groups,tracks_layout,true,matching_group_stats,min_second_distance,max_dist_ratio,max_angle_diff,...
                    unknown_ranking_order,distance_ranking_order,direction_ranking_order);
            end
        end                
    end
    nearby_tracks_sorted=nearby_tracks(sort_idx,:);
end


%end getNearbyTracksSorted
end
