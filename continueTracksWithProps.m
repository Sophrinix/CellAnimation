function output_args=continueTracksWithProps(input_args)
%helper function for the CA tracking module. used to continue the tracks as
%the tracking progresses
%continue the tracks
trackAssignments=input_args.TrackAssignments.Value;
[dummy tracks_sort_idx]=sort(trackAssignments(:,2));
tracks_ids_sorted=trackAssignments(tracks_sort_idx,1);
cur_time=(input_args.CurFrame.Value-1)*input_args.TimeFrame.Value;
centroids=input_args.ObjectCentroids.Value;
props=input_args.Props.Value;
output_args.NewTracks=[tracks_ids_sorted repmat(cur_time,size(tracks_ids_sorted,1),1) centroids props];
output_args.Tracks=[input_args.Tracks.Value; output_args.NewTracks];

%end continueTracks
end