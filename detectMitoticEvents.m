function output_args=detectMitoticEvents(input_args)
%Usage
%This module is used to detect mitotic events in time-lapse movies of cells stained with a nuclear
%stain.
%
%Input Structure Members
%MaxSplitArea – Maximum area a nucleus may have at the time it splits.
%MaxSplitDistance – Nuclei that are further apart than this distance will not be considered as a
%potential split pair.
%MaxSplitEccentricity – Any nucleus with an eccentricity above this value will not be considered a
%split candidate.
%MinSplitEccentricity – Any nucleus with an eccentricity below this value will not be considered a
%split candidate.
%MinTimeForSplit – A cell needs to have a lifespan above this value to be considered a split
%candidate.
%Tracks – Tracks matrix including time stamps and object centroids.
%TracksLayout – Matrix describing the order of the columns in the tracks matrix.
%UntestedIDs - Track IDs to be tested for mitosis.
%
%Output Structure Members
%SplitCells – List of mitotic cell pairs.
%
%Example
%
%detect_mitotic_events_function.InstanceName='DetectMitoticEvents';
%detect_mitotic_events_function.FunctionHandle=@detectMitoticEvents;
%detect_mitotic_events_function.FunctionArgs.Tracks.FunctionInstance='MergeTra
%cks';
%detect_mitotic_events_function.FunctionArgs.Tracks.OutputArg='Tracks';
%detect_mitotic_events_function.FunctionArgs.UntestedIDs.FunctionInstance='Mak
%eAncestryForFirstFrameCells';
%detect_mitotic_events_function.FunctionArgs.UntestedIDs.OutputArg='UntestedID
%s';
%detect_mitotic_events_function.FunctionArgs.TracksLayout.Value=tracks_layout;
%detect_mitotic_events_function.FunctionArgs.MaxSplitArea.Value=TrackStruct.Ma
%xSplitArea;
%detect_mitotic_events_function.FunctionArgs.MinSplitEccentricity.Value=TrackS
%truct.MinSplitEcc;
%detect_mitotic_events_function.FunctionArgs.MaxSplitEccentricity.Value=TrackS
%truct.MaxSplitEcc;
%detect_mitotic_events_function.FunctionArgs.MaxSplitDistance.Value=TrackStruc
%t.MaxSplitDist;
%detect_mitotic_events_function.FunctionArgs.MinTimeForSplit.Value=TrackStruct
%.MinTimeForSplit;
%functions_list=addToFunctionChain(functions_list,detect_mitotic_events_functi
%on);
%…
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.SplitCells.Func
%tionInstance='DetectMitoticEvents';
%make_ancestry_for_cells_entering_frames_function.FunctionArgs.SplitCells.Outp
%utArg='SplitCells';

tracks=input_args.Tracks.Value;
tracks_layout=input_args.TracksLayout.Value;
areaCol=tracks_layout.AreaCol;
eccCol=tracks_layout.EccCol;
timeCol=tracks_layout.TimeCol;
trackIDCol=tracks_layout.TrackIDCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
max_split_area=input_args.MaxSplitArea.Value;
min_split_ecc=input_args.MinSplitEccentricity.Value;
max_split_ecc=input_args.MaxSplitEccentricity.Value;
max_split_dist=input_args.MaxSplitDistance.Value;
min_time_for_split=input_args.MinTimeForSplit.Value;
untested_ids=input_args.UntestedIDs.Value;
split_cells=[];
%these are the cells that have a known parent therefore a known age
cells_with_known_split_frames=java.util.Hashtable;

while (~isempty(untested_ids))
    curID=untested_ids(1);
    cur_track_idx=(tracks(:,trackIDCol)==curID);
    cur_track=tracks(cur_track_idx,:);
    cur_track_median_area=median(cur_track(:,areaCol));    
    cur_track_times=cur_track(:,timeCol);
    track_start_time=cur_track_times(1);
    track_end_time=cur_track_times(end);
    cur_area=cur_track(1,areaCol);
    if (cur_area>1.3*cur_track_median_area)
        %a cell is smaller right after splitting
        untested_ids(1)=[];
        continue;
    end
    if (cur_area>max_split_area)
        %a cell is smaller right after splitting
        untested_ids(1)=[];
        continue;
    end
    cur_ecc=cur_track(1,eccCol);
    if (cur_ecc<min_split_ecc)
        %nuclei are elongated right after splitting
        untested_ids(1)=[];
        continue;
    end
    if (cur_ecc>max_split_ecc)
        %nuclei are not perfect lines
        untested_ids(1)=[];
        continue;
    end
    %get the tracks that exist when this track appears for now just tracks
    %in the current time for the future we might add other times
    existing_tracks_idx=(tracks(:,timeCol)==track_start_time)&(~cur_track_idx);
    existing_tracks=tracks(existing_tracks_idx,:);
    cur_track_centroid=cur_track(1,centroid1Col:centroid2Col);
    existing_tracks_centroids=existing_tracks(:,centroid1Col:centroid2Col);
    %get the tracks that are near our cell    
    dist_to_existing_tracks=hypot(existing_tracks_centroids(:,1)-cur_track_centroid(1),...
        existing_tracks_centroids(:,2)-cur_track_centroid(2));    
    split_candidates_idx=dist_to_existing_tracks<max_split_dist;
    split_candidates=existing_tracks(split_candidates_idx,:);
    if isempty(split_candidates)
        %no possible candidates to merge with so move on to next track
        untested_ids(1)=[];
        continue;
    end    
    %sort the merge candidates by area    
    [dummy sort_idx]=sort(split_candidates(:,areaCol));
    split_candidates=split_candidates(sort_idx,trackIDCol);    
    
    %we have some tracks that may need to be merged with this track
    candidates_nr=size(split_candidates,1);
    for j=1:candidates_nr
        candidateID=split_candidates(j);
        candidate_track=tracks(tracks(:,trackIDCol)==candidateID,:);
        candidate_birth_time=cells_with_known_split_frames.get(candidateID);
        if isempty(candidate_birth_time)
            candidate_start_time=candidate_track(1,timeCol);
        else
            cell_life_span=track_start_time-candidate_birth_time;
            if (cell_life_span<min_time_for_split)
                %this cell has split too recently to be splitting again
                continue;
            end
            candidate_start_time=candidate_birth_time;
        end
        if (candidate_start_time>=track_start_time)
            %this track cannot be a parent of our track
            continue;
        end
        %get the times at which track exists
%         candidate_times=candidate_track(:,timeCol);
%         %get the times when both tracks exist
%         [common_times cur_track_common_idx candidate_track_common_idx]=intersect(cur_track_times,candidate_times);
%         if (length(common_times)<4)
%             continue;
%         end
        %get the centroids at those times
%         cur_track_common_times_centroids=cur_track(cur_track_common_idx,centroid1Col:centroid2Col);
%         candidate_common_times_centroids=candidate_track(candidate_track_common_idx,centroid1Col:centroid2Col);
%         %get the distance between tracks
%         dist_between_tracks=hypot(candidate_common_times_centroids(:,1)-cur_track_common_times_centroids(:,1),...
%             candidate_common_times_centroids(:,2)-cur_track_common_times_centroids(:,2));
        candidate_track_median_area=median(candidate_track(:,areaCol));
        potential_split_idx=candidate_track(:,timeCol)==track_start_time;
        potential_split_params=candidate_track(potential_split_idx,:);
        cur_area=potential_split_params(1,areaCol);
        if (cur_area>1.1*candidate_track_median_area)
            %a cell is smaller right after splitting            
            continue;
        end
        if (cur_area>max_split_area)
            %a cell is smaller right after splitting            
            continue;
        end
        cur_ecc=potential_split_params(1,eccCol);
        if (cur_ecc<min_split_ecc)
            %nuclei are elongated right after splitting            
            continue;
        end
        if (cur_ecc>max_split_ecc)
            %nuclei are not perfect lines         
            continue;
        end
        split_cells=[split_cells; [candidateID curID track_start_time track_end_time]];
        cells_with_known_split_frames.put(candidateID,track_start_time);
        cells_with_known_split_frames.put(curID,track_start_time);
        break;
    end
    untested_ids(1)=[];   
end

output_args.SplitCells=split_cells;

%end detectMitoticEvents
end
