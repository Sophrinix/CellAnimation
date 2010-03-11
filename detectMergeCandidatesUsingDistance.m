function output_args=detectMergeCandidatesUsingDistance(input_args)
%detect tracks that never are further than a small distance apart for
%possible merging
untested_ids=input_args.TrackIDs.Value;
tracks=input_args.Tracks.Value;
max_merge_dist=input_args.MaxMergeDistance.Value;
tracks_layout=input_args.TracksLayout.Value;
trackIDCol=tracks_layout.TrackIDCol;
timeCol=tracks_layout.TimeCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
tracks_to_be_merged=[];

while (~isempty(untested_ids))
    curID=untested_ids(1);
    cur_track_idx=(tracks(:,trackIDCol)==curID);
    cur_track=tracks(cur_track_idx,:);
    cur_track_times=cur_track(:,timeCol);
    track_start_time=cur_track_times(1);
    %get the tracks that exist when this track appears for now just tracks
    %in the current time for the future we might add other times
    existing_tracks_idx=(tracks(:,timeCol)==track_start_time)&(~cur_track_idx);
    existing_tracks=tracks(existing_tracks_idx,:);
    cur_track_centroid=cur_track(1,centroid1Col:centroid2Col);
    existing_tracks_centroids=existing_tracks(:,centroid1Col:centroid2Col);
    %get the tracks that are near our cell    
    dist_to_existing_tracks=hypot(existing_tracks_centroids(:,1)-cur_track_centroid(1),...
        existing_tracks_centroids(:,2)-cur_track_centroid(2));    
    merge_candidates_idx=dist_to_existing_tracks<max_merge_dist;
    merge_candidates=existing_tracks(merge_candidates_idx,:);
    if isempty(merge_candidates)
        %no possible candidates to merge with so move on to next track
        untested_ids(1)=[];
        continue;
    end
    dist_to_existing_tracks=dist_to_existing_tracks(merge_candidates_idx);
    %sort the merge candidates by distance
    [dummy sort_idx]=sort(dist_to_existing_tracks);
    merge_candidates=merge_candidates(sort_idx,trackIDCol);
    
    %we have some tracks that may need to be merged with this track
    candidates_nr=size(merge_candidates,1);
    for j=1:candidates_nr
        candidateID=merge_candidates(j);
        candidate_track=tracks(tracks(:,trackIDCol)==candidateID,:);
        %get the times at which track exists
        candidate_times=candidate_track(:,timeCol);
        %get the times when both tracks exist
        [dummy cur_track_common_idx candidate_track_common_idx]=intersect(cur_track_times,candidate_times);
        %get the centroids at those times
        cur_track_common_times_centroids=cur_track(cur_track_common_idx,centroid1Col:centroid2Col);
        candidate_common_times_centroids=candidate_track(candidate_track_common_idx,centroid1Col:centroid2Col);
        dist_between_tracks=hypot(candidate_common_times_centroids(:,1)-cur_track_common_times_centroids(:,1),...
            candidate_common_times_centroids(:,2)-cur_track_common_times_centroids(:,2));
        if (max(dist_between_tracks)<max_merge_dist)
            %found a track we should merge with
            tracks_to_be_merged=[tracks_to_be_merged; [candidateID curID]];
            %remove the candidateID from the list of tracks to be checked
            untested_ids(untested_ids==candidateID)=[];
            break;
        end        
    end
    untested_ids(1)=[];   
end

output_args.TracksToBeMerged=tracks_to_be_merged;

%end detectMergeCandidatesUsingDistance
end