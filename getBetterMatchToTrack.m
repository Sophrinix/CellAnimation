function best_match_id=getBetterMatchToTrack(cur_track,cells_shape_params,cells_centroids,cells_ids,prev_tracks,matching_groups,...
    track_struct, cells_lbl, prev_cells_lbl)
%figure out which cell of a pair is a better match for the track this
%should only be used with cell pairs otherwise is meaningless
assert(size(cells_shape_params,1)==2);
%figure out which cell is a better match for this track

tracks_layout=track_struct.TracksLayout;
areaCol=tracks_layout.AreaCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
groupIDCol=tracks_layout.MatchGroupIDCol;
solCol=tracks_layout.SolCol;
param_weights=track_struct.DefaultParamWeights;
unknown_param_weights=track_struct.UnknownParamWeights;


track_centroid=cur_track(centroid1Col:centroid2Col);
dist_to_cells=hypot(cells_centroids(:,1)-track_centroid(1), cells_centroids(:,2)-track_centroid(2));
if (isempty(prev_tracks))
    prev_track_centroid=[];
else
    prev_track_centroid=prev_tracks(prev_tracks(:,trackIDCol)==cur_track(:,trackIDCol),centroid1Col:centroid2Col);
end
if isempty(prev_track_centroid)
    track_params=[min(dist_to_cells) cur_track(areaCol:solCol)];
    cells_params=[dist_to_cells cells_shape_params(:,1:solCol-areaCol+1)];
    b_use_direction=false;
else
    prev_angle=atan2(abs(track_centroid(2)-prev_track_centroid(2)), abs(track_centroid(1)-prev_track_centroid(1)));
    possible_angles=atan2(abs(track_centroid(2)-cells_centroids(:,2)), abs(track_centroid(1)-cells_centroids(:,1)));
    track_params=[min(dist_to_cells) prev_angle cur_track(areaCol:solCol)];
    cells_params=[dist_to_cells possible_angles cells_shape_params(:,1:solCol-areaCol+1)];
    b_use_direction=true;
end

group_idx=cur_track(:,groupIDCol);
if (group_idx==0)
    ranking_order=track_struct.UnknownRankingOrder;    
else
    ranking_order=matching_groups(group_idx,:);
end
pair_scores=getPairScoresToSingle(cells_params,track_params,b_use_direction,unknown_param_weights,...
    param_weights,ranking_order,group_idx);
best_match_id=[];
if (pair_scores(1)==pair_scores(2))
    %neither cell is a better match to the track
    return;
end

track_lbl_id=getLabelId(prev_cells_lbl, track_centroid);
if (pair_scores(1)<pair_scores(2))
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(1), track_lbl_id, 0))
        best_match_id=cells_ids(1);
        return;
    end
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(2), track_lbl_id, 0))
        best_match_id=cells_ids(2);
        return;
    end
else
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(2), track_lbl_id, 0))
        best_match_id=cells_ids(2);
        return;
    end
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(1), track_lbl_id, 0))
        best_match_id=cells_ids(1);
        return;
    end
end
    
%end getBetterMatchToTrack
end
