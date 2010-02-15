function [tracks_sorted sort_idx track_scores]=sortTracks(track_ranks,tracks,ranking_order,params_weights)
%sort the tracks according to ranking order
nr_tracks=size(track_ranks,1);
if (nr_tracks==1)
    tracks_sorted=tracks;
    sort_idx=1;
    track_scores=1;
    return;
end
track_ranks_by_relevance=track_ranks(:,ranking_order);
weighted_track_ranks=track_ranks_by_relevance.*repmat(params_weights,nr_tracks,1);
track_scores=sum(weighted_track_ranks,2);
[dummy sort_idx]=sort(track_scores);
tracks_sorted=tracks(sort_idx,:);

%end sortTracks
end
