function output_args=assignCellToTrackUsingAll(input_args)

unassignedIDs=input_args.UnassignedCells.Value;
cells_lbl=input_args.CellsLabel.Value;
prev_cells_lbl=input_args.PreviousCellsLabel.Value;
shape_params=input_args.ShapeParameters.Value;
cells_centroids=input_args.CellsCentroids.Value;
cur_tracks=input_args.CurrentTracks.Value;
prev_tracks=input_args.PreviousTracks.Value;
search_radius=input_args.SearchRadius.Value;
trackAssignments=input_args.TrackAssignments.Value;
track_struct=input_args.TrackStruct.Value;
max_tracks=input_args.MaxTrackID.Value;
tracks=input_args.Tracks.Value;
matching_groups=input_args.MatchingGroups.Value;
params_coeff_var=input_args.ParamsCoeffOfVariation.Value;

%assign current cell to a track
cur_id=unassignedIDs(1);
%first get a list of all tracks in the current search radius
tracks_layout=track_struct.TracksLayout;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

[nearby_tracks_sorted group_idx matching_groups]=getNearbyTracksSorted(cur_id, cells_centroids,shape_params,track_struct,cur_tracks...
    ,prev_tracks,search_radius,matching_groups,tracks,params_coeff_var);
nearby_tracks_ids=nearby_tracks_sorted(:,trackIDCol);
%does list have at least one track?
nearby_tracks_nr=length(nearby_tracks_ids);
for i=1:nearby_tracks_nr
    %pick the best track for current cell
    best_track_id=nearby_tracks_ids(i,trackIDCol);
    track_lbl_id=getLabelId(prev_cells_lbl, nearby_tracks_sorted(i,centroid1Col:centroid2Col));
    if (pathGoesThroughACell(cells_lbl, prev_cells_lbl,cur_id,track_lbl_id,0))
        %resulting path would go through another cell - this track cannot match this cell
        continue;
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
        return;
    else
        %which cell is prefered by the track?
        competing_shape_params=[shape_params(cur_id,:); shape_params(competing_id,:)];
        competing_cells_centroids=[cells_centroids(cur_id,:); cells_centroids(competing_id,:)];
        %sort the two cells with respect of their goodness-of-fit to the
        %track
        preferred_cell_id=getBetterMatchToTrack(nearby_tracks_sorted(i,:),competing_shape_params,competing_cells_centroids,...
            [cur_id;competing_id],prev_tracks,matching_groups,track_struct, cells_lbl, prev_cells_lbl);
        if (isempty(preferred_cell_id))
            continue;
        end
        if (preferred_cell_id==competing_id)
            %the competing cell is preferred does this cell have other
            %tracks it can get?
            if (canCellGetAnotherTrack(cur_id,nearby_tracks_sorted(i+1:nearby_tracks_nr,:),prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,true))            
               %it does. we'll have to leave this track to the
                %cell with the stronger claim
                continue;
            end
            %this cell has no other tracks it can connect to. does the
            %competing cell have other tracks it can get?
            other_tracks_sorted=getNearbyTracksSorted(competing_id, cells_centroids,shape_params,track_struct,cur_tracks,...
                prev_tracks,search_radius,matching_groups,tracks,params_coeff_var);
            %remove the current track
            other_tracks_sorted(other_tracks_sorted(:,trackIDCol)==nearby_tracks_sorted(i,trackIDCol),:)=[];
            if (~canCellGetAnotherTrack(competing_id,other_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false))            
               %this track is the last option for the competing cell
                %as well. we'll have to leave it to it since it is
                %preferred by the track
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
            return;
        else
            %this cell is preferred by the track
            if (~canCellGetAnotherTrack(cur_id,nearby_tracks_sorted(i+1:nearby_tracks_nr,:),prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false))            
               %this cell has no other tracks it can get
                %bump the cell with the weaker claim
                unassignedIDs(1)=trackAssignments(track_idx,2);
                trackAssignments(track_idx,2)=cur_id;
                output_args.UnassignedIDs=unassignedIDs;
                output_args.TrackAssignments=trackAssignments;
                output_args.MatchingGroups=matching_groups;
                output_args.GroupIndex=group_idx;
                return;
            end
            %does the competing cell have other options?
            other_tracks_sorted=getNearbyTracksSorted(competing_id, cells_centroids,shape_params,track_struct,cur_tracks,...
                prev_tracks,search_radius,matching_groups,tracks,params_coeff_var);
            %remove the current track
            other_tracks_sorted(other_tracks_sorted(:,trackIDCol)==nearby_tracks_sorted(i,trackIDCol),:)=[];            
            if (canCellGetAnotherTrack(competing_id,other_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false))            
                %yes relinquish the track to this cell with the stronger
                %claim
                unassignedIDs(1)=trackAssignments(track_idx,2);
                trackAssignments(track_idx,2)=cur_id;
                output_args.UnassignedIDs=unassignedIDs;
                output_args.TrackAssignments=trackAssignments;
                output_args.MatchingGroups=matching_groups;
                output_args.GroupIndex=group_idx;
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

%end assignCellToTrackUsingAll
end
