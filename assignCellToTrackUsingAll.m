function output_args=assignCellToTrackUsingAll(input_args)

unassignedIDs=input_args.UnassignedCells.Value;
cells_lbl=input_args.CellsLabel.Value;
prev_cells_lbl=input_args.PreviousCellsLabel.Value;
shape_params=input_args.ShapeParameters.Value;
cells_centroids=input_args.CellsCentroids.Value;
cur_tracks=input_args.CurrentTracks.Value;
prev_tracks=input_args.PreviousTracks.Value;
search_radius_pct=input_args.SearchRadiusPct.Value;
trackAssignments=input_args.TrackAssignments.Value;
tracks_layout=input_args.TracksLayout.Value;
max_tracks=input_args.MaxTrackID.Value;
matching_groups=input_args.MatchingGroups.Value;
matching_groups_stats=input_args.MatchingGroupsStats.Value;
params_coeff_var=input_args.ParamsCoeffOfVariation.Value;
excluded_tracks=input_args.ExcludedTracks.Value;
relevant_params_idx=input_args.RelevantParametersIndex.Value;
params_for_sure_match=input_args.NrParamsForSureMatch.Value;
param_weights=input_args.DefaultParamWeights.Value;
unknown_param_weights=input_args.UnknownParamWeights.Value;
distance_ranking_order=input_args.DistanceRankingOrder.Value;
direction_ranking_order=input_args.DirectionRankingOrder.Value;
unknown_ranking_order=input_args.UnknownRankingOrder.Value;
min_second_distance=input_args.MinSecondDistance.Value;
max_dist_ratio=input_args.MaxDistRatio.Value;
max_angle_diff=input_args.MaxAngleDiff.Value;
b_check_path=input_args.CheckCellPath.Value;
max_search_dist=input_args.MaxSearchRadius.Value;
min_search_dist=input_args.MinSearchRadius.Value;

%assign current cell to a track
cur_id=unassignedIDs(1);
%first get a list of all tracks in the current search radius
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

[nearby_tracks_sorted group_idx matching_groups]=getNearbyTracksSorted(cur_id, cells_centroids,shape_params,tracks_layout,cur_tracks...
    ,prev_tracks,search_radius_pct,matching_groups,params_coeff_var,relevant_params_idx,matching_groups_stats,params_for_sure_match,...
    param_weights,unknown_param_weights,distance_ranking_order,direction_ranking_order,unknown_ranking_order,min_second_distance,...
    max_dist_ratio,max_angle_diff,max_search_dist,min_search_dist);
if (isempty(nearby_tracks_sorted))    
    nearby_tracks_nr=0;
else
    nearby_tracks_ids=nearby_tracks_sorted(:,trackIDCol);
    %does list have at least one track?
    nearby_tracks_nr=length(nearby_tracks_ids);
end
for i=1:nearby_tracks_nr
    %pick the best track for current cell
    best_track_id=nearby_tracks_ids(i,trackIDCol);
    track_lbl_id=getLabelId(prev_cells_lbl, nearby_tracks_sorted(i,centroid1Col:centroid2Col));
    if (max(excluded_tracks{cur_id}==best_track_id)==1)
        %can't get this track
        continue;
    end
    if (b_check_path)
        if (pathGoesThroughACell(cells_lbl, prev_cells_lbl,cur_id,track_lbl_id,0))
            %resulting path would go through another cell - this track cannot match this cell
            continue;
        end
    end
    if (isempty(trackAssignments))
        track_idx=[];
        competing_id=[];
    else
        track_idx=find(trackAssignments(:,1)==best_track_id,1);
        competing_id=trackAssignments(track_idx,2);
    end
    %is the track this cell wants claimed?
    if (isempty(track_idx))
        %track is not claimed-assign it to this cell
        trackAssignments=[trackAssignments; [best_track_id cur_id]];
        %remove cell from unassigned list
        unassignedIDs(1)=[];
        output_args.UnassignedIDs=unassignedIDs;
        output_args.TrackAssignments=trackAssignments;
        output_args.MatchingGroups=matching_groups;
        output_args.GroupIndex=group_idx;
        output_args.ExcludedTracks=excluded_tracks;
        return;
    else
        %which cell is prefered by the track?
        competing_shape_params=[shape_params(cur_id,:); shape_params(competing_id,:)];
        competing_cells_centroids=[cells_centroids(cur_id,:); cells_centroids(competing_id,:)];
        %sort the two cells with respect of their goodness-of-fit to the
        %track
        preferred_cell_id=getBetterMatchToTrack(nearby_tracks_sorted(i,:),competing_shape_params,competing_cells_centroids,[cur_id;competing_id]...
            ,prev_tracks,matching_groups,tracks_layout, cells_lbl, prev_cells_lbl, relevant_params_idx, param_weights,...
            unknown_param_weights,unknown_ranking_order);
        if (isempty(preferred_cell_id))
            continue;
        end
        if (preferred_cell_id==competing_id)
            %the competing cell is preferred does this cell have other
            %tracks it can get?
            available_tracks_sorted=nearby_tracks_sorted(i+1:nearby_tracks_nr,:);
            excluded_tracks_idx=ismember(available_tracks_sorted(:,trackIDCol),excluded_tracks{cur_id});
            available_tracks_sorted(excluded_tracks_idx,:)=[];            
            if (canCellGetAnotherTrack(cur_id,available_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    tracks_layout,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,true,relevant_params_idx,...
                    param_weights,unknown_param_weights,unknown_ranking_order,b_check_path))            
               %it does. we'll have to leave this track to the
                %cell with the stronger claim
                continue;
            end
            %this cell has no other tracks it can connect to. does the
            %competing cell have other tracks it can get?
            other_tracks_sorted=getNearbyTracksSorted(competing_id, cells_centroids,shape_params,tracks_layout,cur_tracks,...
                prev_tracks,search_radius_pct,matching_groups,params_coeff_var,relevant_params_idx,matching_groups_stats,params_for_sure_match,...
                param_weights,unknown_param_weights,distance_ranking_order,direction_ranking_order,unknown_ranking_order,...
                min_second_distance,max_dist_ratio,max_angle_diff,max_search_dist,min_search_dist);
            %remove the current track
            other_tracks_sorted(other_tracks_sorted(:,trackIDCol)==nearby_tracks_sorted(i,trackIDCol),:)=[];
            %remove any tracks that have already been excluded
            excluded_tracks_idx=ismember(other_tracks_sorted(:,trackIDCol),excluded_tracks{competing_id});
            other_tracks_sorted(excluded_tracks_idx,:)=[];
            if (isempty(other_tracks_sorted)||(~canCellGetAnotherTrack(competing_id,other_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    tracks_layout,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false,relevant_params_idx,...
                    param_weights,unknown_param_weights,unknown_ranking_order,b_check_path)))            
               %this track is the last option for the competing cell
                %as well. we'll have to leave it to it since it is
                %preferred by the track
                excluded_tracks{cur_id}=[excluded_tracks{cur_id}; best_track_id];
                continue;
            end
            %the competing cell has other options this cell doesn't so take
            %the track even though it has a weaker claim
            unassignedIDs(1)=competing_id;
            trackAssignments(track_idx,2)=cur_id;
            output_args.UnassignedIDs=unassignedIDs;
            output_args.TrackAssignments=trackAssignments;
            output_args.MatchingGroups=matching_groups;
            output_args.GroupIndex=group_idx;
            output_args.ExcludedTracks=excluded_tracks;
            return;
        else
            %this cell is preferred by the track
            available_tracks_sorted=nearby_tracks_sorted(i+1:nearby_tracks_nr,:);
            excluded_tracks_idx=ismember(available_tracks_sorted(:,trackIDCol),excluded_tracks{cur_id});
            available_tracks_sorted(excluded_tracks_idx,:)=[];
            if (isempty(available_tracks_sorted)||(~canCellGetAnotherTrack(cur_id,available_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    tracks_layout,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false,relevant_params_idx,...
                    param_weights,unknown_param_weights,unknown_ranking_order,b_check_path)))
               %this cell has no other tracks it can get
                %bump the cell with the weaker claim
                unassignedIDs(1)=trackAssignments(track_idx,2);
                trackAssignments(track_idx,2)=cur_id;
                output_args.UnassignedIDs=unassignedIDs;
                output_args.TrackAssignments=trackAssignments;
                output_args.MatchingGroups=matching_groups;
                output_args.GroupIndex=group_idx;
                excluded_tracks{competing_id}=[excluded_tracks{competing_id}; best_track_id];
                output_args.ExcludedTracks=excluded_tracks;
                return;
            end
            %does the competing cell have other options?
            other_tracks_sorted=getNearbyTracksSorted(competing_id, cells_centroids,shape_params,tracks_layout,cur_tracks,...
                prev_tracks,search_radius_pct,matching_groups,params_coeff_var,relevant_params_idx,matching_groups_stats,params_for_sure_match,...
                param_weights,unknown_param_weights,distance_ranking_order,direction_ranking_order,unknown_ranking_order,min_second_distance,...
                max_dist_ratio,max_angle_diff,max_search_dist,min_search_dist);
            %remove the current track
            other_tracks_sorted(other_tracks_sorted(:,trackIDCol)==nearby_tracks_sorted(i,trackIDCol),:)=[];
            %remove any tracks that have already been excluded
            excluded_tracks_idx=ismember(other_tracks_sorted(:,trackIDCol),excluded_tracks{competing_id});
            other_tracks_sorted(excluded_tracks_idx,:)=[];            
            if (canCellGetAnotherTrack(competing_id,other_tracks_sorted,prev_cells_lbl,cells_lbl,tracks_layout,trackAssignments,shape_params,...
                    cells_centroids,prev_tracks,matching_groups,false,relevant_params_idx,param_weights,unknown_param_weights,...
                    unknown_ranking_order,b_check_path))            
                %yes relinquish the track to this cell with the stronger
                %claim
                unassignedIDs(1)=trackAssignments(track_idx,2);
                trackAssignments(track_idx,2)=cur_id;
                output_args.UnassignedIDs=unassignedIDs;
                output_args.TrackAssignments=trackAssignments;
                output_args.MatchingGroups=matching_groups;
                output_args.GroupIndex=group_idx;
                excluded_tracks{competing_id}=[excluded_tracks{competing_id}; best_track_id];
                output_args.ExcludedTracks=excluded_tracks;
                return;
            else
                %this cell can get other tracks, the competing cell
                %can't. let it keep the track even though it has a
                %weaker claim
                continue; 
            end            
        end
    end
end


%list of potential tracks is empty
%start new track
if isempty(trackAssignments)
    max_track_id=max([cur_tracks(:,trackIDCol);max_tracks]);
else
    max_track_id=max([cur_tracks(:,trackIDCol); trackAssignments(:,1); max_tracks]);
end
trackAssignments=[trackAssignments; [max_track_id+1 cur_id]];
%remove cell from unassigned list
unassignedIDs(1)=[];

output_args.UnassignedIDs=unassignedIDs;
output_args.TrackAssignments=trackAssignments;
output_args.MatchingGroups=matching_groups;
output_args.GroupIndex=group_idx;
output_args.ExcludedTracks=excluded_tracks;

%end assignCellToTrackUsingAll
end
