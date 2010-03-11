function b_cell_can_get_another_track=canCellGetAnotherTrack(cur_id,nearby_tracks_sorted,prev_cells_lbl,cells_lbl,...
    tracks_layout,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,b_bumping_allowed,relevant_params_idx,...
    param_weights,unknown_param_weights,unknown_ranking_order)
if (isempty(nearby_tracks_sorted))
    b_cell_can_get_another_track=false;
    return;
end
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
b_found_track=false;
for i=1:size(nearby_tracks_sorted,1)
    track_lbl_id=getLabelId(prev_cells_lbl,nearby_tracks_sorted(i,centroid1Col:centroid2Col));
    if (pathGoesThroughACell(cells_lbl,prev_cells_lbl,cur_id,track_lbl_id,0))
        continue;
    end
    if (isempty(trackAssignments))
        track_idx=[];
    else        
        track_idx=find(trackAssignments(:,1)==nearby_tracks_sorted(i,trackIDCol),1);
    end
    if (isempty(track_idx))
        b_found_track=true;
        break;
    else
        if (~b_bumping_allowed)
            %not allowed to bump other cells
            continue;
        end
        test_id=trackAssignments(track_idx,2);
        %which cell is prefered by the track?
        test_shape_params=[shape_params(cur_id,:); shape_params(test_id,:)];
        test_cells_centroids=[cells_centroids(cur_id,:); cells_centroids(test_id,:)];
        %sort the two cells with respect of their goodness-of-fit to the
        %track
        preferred_cell_id=getBetterMatchToTrack(nearby_tracks_sorted(i,:),test_shape_params,test_cells_centroids,...
            [cur_id;test_id],prev_tracks,matching_groups,tracks_layout,cells_lbl,prev_cells_lbl,relevant_params_idx,param_weights,...
            unknown_param_weights,unknown_ranking_order);
        if (isempty(preferred_cell_id)||(preferred_cell_id==test_id))
            continue;
        else
            %found another track which this cell can use
            b_found_track=true;
            break;
        end
    end
end
if (b_found_track)
    b_cell_can_get_another_track=true;
else
    b_cell_can_get_another_track=false;
end

%end canCellGetAnotherTrack
end
