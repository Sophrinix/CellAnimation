function output_args=assignCellToTrackUsingAll(input_args)
%Usage
%This module tracks objects in a time-lapse sequence of label matrices. It uses distance, speed,
%direction and shape parameters to determine which candidate object best matches a track. It
%can be optimized for tracking fast moving directional objects or slow moving objects.
%
%Input Structure Members
%CheckCellPath – To allow paths that go through another cell set this value to true otherwise set
%it to false.
%CellsCentroids – Current object centroids.
%CellsLabel – The current time step label matrix.
%CurrentTracks – Matrix containing the track assignments and shape parameters for the objects
%in the previous frame.
%DefaultParamWeights – A set of weights is assigned to each parameter based on its prediction
%power. Parameters with high prediction power are assigned high weights and parameters with
%low prediction power are assigned lower weights. If an object can be assigned to a matching
%group or is a sure match for a track the weights listed in this variable are used.
%DirectionRankingOrder – When the order of the parameters based on prediction power cannot
%be determined using a group match a set of default parameter ranks are used. The parameter
%order for fast directional objects is provided in this variable.
%DistanceRankingOrder – When the order of the parameters based on prediction power cannot
%be determined using a group match a set of default parameter ranks are used. The parameter
%order for slow-moving objects is provided in this variable.
%ExcludedTracks – List of track assignments that should not be changed.
%FrontParams – To force a set of parameters to the front so they are heavily weighted enter their
%column indices in the variable, otherwise set the variable to an empty vector.
%MatchingGroups – Matrix of current matching groups (vectors of shape or motility indices
%ordered by their prediction power).
%MatchingGroupsStats – Matrix of mean values for each parameter in each group.
%MaxAngleDiff – The maximum allowed angle difference between a track and a candidate object.
%If the angle is larger than this value direction ranking will not be used for this object.
%MaxDistRatio – The maximum allowed distance ratio between the two nearest candidate
%objects. If the ratio is higher than this value distance ranking will not be used.
%MaxSearchRadius - Sets an absolute lower bound for the search radius to prevent selecting too
%few candidate objects for a track.
%MaxTrackID – Current maximum track ID.
%MinSecondDistance – Minimum significant distance between the closest candidate object to a
%track and the second closest. Used to determine when distance should be used as a ranking
%parameter.
%MinSearchRadius – Sets an absolute higher bound for the search radius to prevent selecting
%too many candidate objects for a track.
%NrParamsForSureMatch – This value is used to indicate the minimum number of closest
%matches between a candidate object parameters and a track’s object parameters that make the
%candidate object a sure match to the track.
%ParamsCoeffOfVariation – Matrix containing the coefficient of variation for each parameter.
%PreviousCellsLabel – The matrix label from the previous time step.
%PreviousTracks – Matrix containing the track assignments and shape parameters for the objects
%in the frame previous to those in CurrentTracks.
%RelevantParametersIndex – Shape or motility parameters that have been determined to be
%
%irrelevant for tracking the objects can be eliminated by setting the corresponding index in the
%variable to false. This indicates to the module not to use the parameters in computing track
%assignment probabilities.
%SearchRadiusPct – This value determines the size of the neighborhood from which candidate
%objects for matching the track are selected. It is a multiple of the distance to the nearest
%candidate in the current frame. Setting this variable equal to 1 turns this module into a nearest-
%neighbor algorithm (only the nearest cell can be a candidate). It does not make sense to have a
%value lower than 1.
%ShapeParameters – Shape parameters (area, eccentricity, perimeter, etc.) extracted from the
%current label.
%TrackAssignments – List of track assignments that have already been completed.
%TracksLayout – Matrix describing the order of the columns in the tracks matrix.
%UnassignedCells – List of object IDs currently unassigned.
%UnknownParamWeights – A set of weights is assigned to each parameter based on its
%prediction power. Parameters with high prediction power are assigned high weights and
%parameters with low prediction power are assigned lower weights. If an object cannot be
%assigned to a matching group and is not a sure match for a track the weights listed in this
%variable are used.
%UnknownRankingOrder – When the order of the parameters based on prediction power cannot
%be determined using a group match a set of default parameter ranks are used. If the objects
%cannot be categorized as either slow-moving or fast directional the parameter order provided in
%this variable is used.
%
%Output Structure Members
%UnassignedIDs – List of object IDs currently unassigned.
%TrackAssignments – List of track assignments that have already been completed.
%MatchingGroups – Matrix of mean values for each parameter in each group.
%GroupIndex – Indicates the index of the group to which the object has been assigned.
%ExcludedTracks – List of track assignments that should not be changed.
%
%Example
%
%assign_cell_to_track_function.InstanceName='AssignCellToTrackUsingAll';
%assign_cell_to_track_function.FunctionHandle=@assignCellToTrackUsingAll;
%assign_cell_to_track_function.FunctionArgs.UnassignedCells.FunctionInstance='
%AssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.UnassignedCells.InputArg='Unassign
%edCells';
%assign_cell_to_track_function.FunctionArgs.ExcludedTracks.FunctionInstance='A
%ssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.ExcludedTracks.InputArg='ExcludedT
%racks';
%assign_cell_to_track_function.FunctionArgs.CellsLabel.FunctionInstance='Assig
%nCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.CellsLabel.InputArg='CellsLabel';
%assign_cell_to_track_function.FunctionArgs.PreviousCellsLabel.FunctionInstanc
%e='AssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.PreviousCellsLabel.InputArg='Previ
%ousCellsLabel';
%assign_cell_to_track_function.FunctionArgs.ShapeParameters.FunctionInstance='
%
%AssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.ShapeParameters.InputArg='ShapePar
%ameters';
%assign_cell_to_track_function.FunctionArgs.CellsCentroids.FunctionInstance='A
%ssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.CellsCentroids.InputArg='CellsCent
%roids';
%assign_cell_to_track_function.FunctionArgs.CurrentTracks.FunctionInstance='As
%signCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.CurrentTracks.InputArg='CurrentTra
%cks';
%assign_cell_to_track_function.FunctionArgs.CheckCellPath.Value=true;
%assign_cell_to_track_function.FunctionArgs.FrontParams.Value=[];
%assign_cell_to_track_function.FunctionArgs.MaxSearchRadius.Value=Inf;
%assign_cell_to_track_function.FunctionArgs.MinSearchRadius.Value=0;
%assign_cell_to_track_function.FunctionArgs.SearchRadiusPct.Value=1.5;
%assign_cell_to_track_function.FunctionArgs.TrackAssignments.FunctionInstance=
%'AssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.TrackAssignments.InputArg='TrackAs
%signments';
%assign_cell_to_track_function.FunctionArgs.MaxTrackID.FunctionInstance='Assig
%nCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.MaxTrackID.InputArg='MaxTrackID';
%assign_cell_to_track_function.FunctionArgs.Tracks.FunctionInstance='AssignCel
%lsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.Tracks.InputArg='Tracks';
%assign_cell_to_track_function.FunctionArgs.MatchingGroups.FunctionInstance='A
%ssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.MatchingGroups.InputArg='MatchingG
%roups';
%assign_cell_to_track_function.FunctionArgs.MatchingGroupsStats.FunctionInstan
%ce='AssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.MatchingGroupsStats.InputArg='Matc
%hingGroupsStats';
%assign_cell_to_track_function.FunctionArgs.ParamsCoeffOfVariation.FunctionIns
%tance='AssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.ParamsCoeffOfVariation.InputArg='P
%aramsCoeffOfVariation';
%assign_cell_to_track_function.FunctionArgs.PreviousTracks.FunctionInstance='A
%ssignCellsToTracksLoop';
%assign_cell_to_track_function.FunctionArgs.PreviousTracks.InputArg='PreviousT
%racks';
%assign_cell_to_track_function.FunctionArgs.TracksLayout.Value=tracks_layout;
%assign_cell_to_track_function.FunctionArgs.RelevantParametersIndex.Value=...
%[true true true false true false true true false];
%assign_cell_to_track_function.FunctionArgs.NrParamsForSureMatch.Value=TrackSt
%ruct.NrParamsForSureMatch;
%assign_cell_to_track_function.FunctionArgs.DefaultParamWeights.Value=TrackStr
%uct.DefaultParamWeights;
%assign_cell_to_track_function.FunctionArgs.UnknownParamWeights.Value=TrackStr
%uct.UnknownParamWeights;
%assign_cell_to_track_function.FunctionArgs.DistanceRankingOrder.Value=TrackSt
%ruct.DistanceRankingOrder;
%assign_cell_to_track_function.FunctionArgs.DirectionRankingOrder.Value=TrackS
%truct.DirectionRankingOrder;
%assign_cell_to_track_function.FunctionArgs.UnknownRankingOrder.Value=TrackStr
%uct.UnknownRankingOrder;
%
%assign_cell_to_track_function.FunctionArgs.MinSecondDistance.Value=TrackStruc
%t.MinSecondDistance;
%assign_cell_to_track_function.FunctionArgs.MaxDistRatio.Value=TrackStruct.Max
%DistRatio;
%assign_cell_to_track_function.FunctionArgs.MaxAngleDiff.Value=TrackStruct.Max
%AngleDiff;
%assign_cells_to_tracks_functions=addToFunctionChain(assign_cells_to_tracks_fu
%nctions,assign_cell_to_track_function);
%…
%assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.FunctionInstance='Ma
%keUnassignedCellsList';
%assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.OutputArg='Unassigne
%dCellsIDs';
%assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.FunctionInstance2='A
%ssignCellToTrackUsingAll';
%assign_cells_to_tracks_loop.FunctionArgs.UnassignedCells.OutputArg2='Unassign
%edIDs';
%assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.FunctionInstance='Mak
%eExcludedTracksList';
%assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.OutputArg='ExcludedTr
%acks';
%assign_cells_to_tracks_loop.FunctionArgs.ExcludedTracks.FunctionInstance2='As
%signCellToTrackUsingAll';
%assign_cells_to_tracks_loop.FunctionArgs.TrackAssignments.FunctionInstance2='
%AssignCellToTrackUsingAll';
%assign_cells_to_tracks_loop.FunctionArgs.TrackAssignments.OutputArg2='TrackAs
%signments';
%assign_cells_to_tracks_loop.FunctionArgs.MatchingGroups.FunctionInstance2='As
%signCellToTrackUsingAll';
%assign_cells_to_tracks_loop.FunctionArgs.MatchingGroups.OutputArg2='MatchingG
%roups';
%…
%set_group_index_function.FunctionArgs.GroupIndex.FunctionInstance='AssignCell
%ToTrackUsingAll';
%set_group_index_function.FunctionArgs.GroupIndex.OutputArg='GroupIndex';

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
front_params=input_args.FrontParams.Value;

[nearby_tracks_sorted group_idx matching_groups]=getNearbyTracksSorted(cur_id, cells_centroids,shape_params,tracks_layout,cur_tracks...
    ,prev_tracks,search_radius_pct,matching_groups,params_coeff_var,relevant_params_idx,matching_groups_stats,params_for_sure_match,...
    param_weights,unknown_param_weights,distance_ranking_order,direction_ranking_order,unknown_ranking_order,min_second_distance,...
    max_dist_ratio,max_angle_diff,max_search_dist,min_search_dist,front_params);
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
                min_second_distance,max_dist_ratio,max_angle_diff,max_search_dist,min_search_dist,front_params);
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
                max_dist_ratio,max_angle_diff,max_search_dist,min_search_dist,front_params);
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
