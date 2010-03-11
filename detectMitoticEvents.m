function output_args=detectMitoticEvents(input_args)
%detect any mitotic events

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
untested_ids=input_args.UntestedIDs.Value;
split_cells=[];

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
        candidate_start_time=candidate_track(1,timeCol);
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
        break;
    end
    untested_ids(1)=[];   
end

output_args.SplitCells=split_cells;

%end detectMitoticEvents
end