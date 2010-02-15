function [ranking_order matching_groups group_idx]=addToMatchingGroups(matching_groups,cur_shape_params,nearby_params,...
    params_coeff_var,best_fit_idx,min_reliable_params, track_ranks, track_struct)
%we need to rank parameters by how near they are to their former values
%then once a ranking order is determined assign it to a matching_group. if
%none exists with the same ranking order create a new one. the first two
%parameters (distance and direction) are treated differently in that they
%are either first rank or last rank predictors.
best_fit_params=nearby_params(best_fit_idx,:);
matched_params=[cur_shape_params; best_fit_params];
%calculate the sd of the matched params and compare it with the sd of the
%nearby_params. parameters for which the sd of the matched params is
%greater than or equal to the sd of nearby_params are unreliable for
%ranking
sd_best_fit_params=std(matched_params(:,3:end));
min_params=min(matched_params);
max_params=max(matched_params);
pct_diff=1-min_params./max_params; %this way i only get values from 0-100%
smallest_pct_change=pct_diff(3:end)./params_coeff_var;
[dummy ranking_order]=sort(smallest_pct_change);
ranking_order=ranking_order+2;

if (size(nearby_params,1)==1)
    reliable_params_col=[1 2 3 4 5 6 7 8 9];
    ranking_order=[1 2 ranking_order];
else
    sd_nearby_params=std(nearby_params(:,3:end));
    reliable_params_col=find(sd_best_fit_params<sd_nearby_params)+2;
    %determine how reliable distance and direction are
    [dummy closest_distance_idx]=min(track_ranks(:,1));
    [dummy closest_angle_idx]=min(track_ranks(:,2));
    if (closest_angle_idx==closest_distance_idx)
        %both nearest distance and nearest angle point to the same cell
        %both distance and angle are reliable for this cell
        reliable_params_col=[1 2 reliable_params_col];
        ranking_order=[1 2 ranking_order];
    else
        %nearest distance and angle point to different cells
        %use the other parameters to pick which one is right
        angle_score=sum(track_ranks(closest_angle_idx,:));
        dist_score=sum(track_ranks(closest_distance_idx,:));
        if (abs(angle_score-dist_score)>2)
            %we have a clear favorite
            if (angle_score<dist_score)
                %direction is most significant
                reliable_params_col=[2 reliable_params_col];
                ranking_order=[2 ranking_order 1];
            else
                %distance is most significant
                reliable_params_col=[1 reliable_params_col 2];
                ranking_order=[1 ranking_order 2];
            end
        else
            angle_diffs_sorted=sort(nearby_params(:,2));
            distances_sorted=sort(nearby_params(:,1));
            dist_ratio=distances_sorted(1)/distances_sorted(2);
            max_angle_diff=track_struct.MaxAngleDiff;
            if ((angle_diffs_sorted(1)<max_angle_diff)&&(abs(angle_diffs_sorted(1)-angle_diffs_sorted(2))>max_angle_diff))
                %direction is most significant
                reliable_params_col=[2 reliable_params_col];
                ranking_order=[2 ranking_order 1];
            elseif ((distances_sorted(2)>track_struct.MinSecondDistance)&&(dist_ratio<track_struct.MaxDistRatio))
                %distance is most significant
                reliable_params_col=[1 reliable_params_col 2];
                ranking_order=[1 ranking_order 2];
            else
                %can't determine which is more reliable use both with
                %slight pref for distance
                reliable_params_col=[1 2 reliable_params_col];
                ranking_order=[1 2 ranking_order];
            end            
        end    
    end
end

reliable_params_idx=ismember(ranking_order,reliable_params_col);
%put the reliable params first
ranking_order=[ranking_order(reliable_params_idx) ranking_order(~reliable_params_idx)];
if (length(reliable_params_col)<min_reliable_params)
    %not enough reliable params to create a matching group
    group_idx=0;
    return;
end
nr_groups=size(matching_groups,1);
if (nr_groups==0)
    matching_groups=ranking_order;
    group_idx=1;
    return;
end
ranking_diff=matching_groups-repmat(ranking_order,nr_groups,1);
ranking_fit=sum(abs(ranking_diff),2);
group_idx=find(ranking_fit==0);
if (isempty(group_idx))
    %doesn't match any of the existing groups - create a new one
    matching_groups=[matching_groups; ranking_order];
    group_idx=nr_groups+1;
end

%end addToMatchingGroups
end