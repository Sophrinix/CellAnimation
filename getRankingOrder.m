function [ranking_order group_idx]=getRankingOrder(cur_shape_params,nearby_shape_params,nearby_ranks,shape_params,...
    tracks,matching_groups,track_struct,bUseDirection)
%we need to figure out which parameters to use first when trying to match
%this cell to a track - this can be done if the cell can be assigned to a
%matching group. if not we'll assign a default ranking_order. determine if
%we need a distance-biased or direction-biased ranking order
distanceCol=1;
angleCol=2;
tracks_layout=track_struct.TracksLayout;
start_params_col=tracks_layout.AreaCol;
end_params_col=tracks_layout.SolCol;
group_id_col=tracks_layout.MatchGroupIDCol;
[dummy closest_distance_idx]=min(nearby_ranks(:,distanceCol));
[dummy closest_angle_idx]=min(nearby_ranks(:,angleCol));
bDirection=false;
bDistance=false;
if (closest_angle_idx~=closest_distance_idx)
    %nearest distance and angle point to different cells
    %use the other parameters to pick which one is right
    angle_score=sum(nearby_ranks(closest_angle_idx,:)==1);
    dist_score=sum(nearby_ranks(closest_distance_idx,:)==1);
    if (abs(angle_score-dist_score)>2)
        %we have a clear favorite
        if (angle_score<dist_score)
            if (bUseDirection)
                %use direction matching groups
                if (~isempty(matching_groups))
                    matching_groups=matching_groups(matching_groups(:,1)==2,:);
                end
                bDirection=true;
            end
        else
            %use distance matching groups
            if (~isempty(matching_groups))
                matching_groups=matching_groups(matching_groups(:,1)==1,:);
            end
            bDistance=true;
        end
    else
        %no clear favorite - use more details
        %if one of the cells is a lot closer than the others use distance
        distances_sorted=sort(nearby_shape_params(:,distanceCol));
        dist_ratio=distances_sorted(1)/distances_sorted(2);
        if ((distances_sorted(2)>track_struct.MinSecondDistance)&&(dist_ratio<track_struct.MaxDistRatio))
            %use distance
            %use distance matching groups
            if (~isempty(matching_groups))
                matching_groups=matching_groups(matching_groups(:,1)==1,:);
            end
            bDistance=true;
        end
        %if one angle is within 20 degress of the previous direction and
        %all other angles are further than 20 degrees from our angle use
        %direction
        angle_diffs_sorted=sort(nearby_shape_params(:,2));
        max_angle_diff=track_struct.MaxAngleDiff;
        if ((angle_diffs_sorted(1)<max_angle_diff)&&(abs(angle_diffs_sorted(1)-angle_diffs_sorted(2))>max_angle_diff)&&bUseDirection)
            %use direction matching groups
            if (~isempty(matching_groups))
                matching_groups=matching_groups(matching_groups(:,1)==2,:);
            end
            bDirection=true;
        end
    end
end

if (isempty(matching_groups))
    if (bDistance)
        ranking_order=track_struct.DistanceRankingOrder;
    elseif (bDirection)
        if (bDistance)
            ranking_order=track_struct.UnknownRankingOrder;
        else
            ranking_order=track_struct.DirectionRankingOrder;
        end
    else
        ranking_order=track_struct.UnknownRankingOrder;
    end    
    group_idx=0;
    return;
end
nr_groups=size(matching_groups,1);
group_diff=zeros(nr_groups,end_params_col-start_params_col+1);
cur_params=cur_shape_params(:,1:end_params_col-start_params_col+1);
for i=1:nr_groups
    group_params_idx=(tracks(:,group_id_col)==i);
    group_params_1=tracks(group_params_idx,start_params_col:end_params_col);
    group_params_idx=(shape_params(:,group_id_col-start_params_col+1)==i);
    group_params=[group_params_1; shape_params(group_params_idx,1:(end_params_col-start_params_col+1))];
    group_stats=mean(group_params,1);
    group_diff(i,:)=abs(group_stats-cur_params);
end
[dummy sort_idx]=sort(group_diff);
ranks_sum=sum(sort_idx,2);
[dummy group_idx]=min(ranks_sum);
ranking_order=matching_groups(group_idx,:);

%end getRankingOrder
end
