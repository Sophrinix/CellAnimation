function output_args=continueTracks(input_args)

%continue the tracks
trackAssignments=input_args.TrackAssignments.Value;
[dummy tracks_sort_idx]=sort(trackAssignments(:,2));
tracks_ids_sorted=trackAssignments(tracks_sort_idx,1);
cur_time=(input_args.CurFrame.Value-1)*input_args.TimeFrame.Value;
output_args.NewTracks=[tracks_ids_sorted repmat(cur_time,size(tracks_ids_sorted,1),1) input_args.CellsCentroids.Value...
    input_args.ShapeParameters.Value];
output_args.Tracks=[input_args.Tracks.Value; output_args.NewTracks];

%end continueTracks
end