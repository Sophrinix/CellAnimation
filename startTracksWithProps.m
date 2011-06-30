function output_args=startTracksWithProps(input_args)
%tracks - and other properties that will be added to the track matrix
object_centroids=input_args.ObjectCentroids.Value;
cur_time=repmat((input_args.CurFrame.Value-1)*input_args.TimeFrame.Value,size(object_centroids,1),1);
track_ids=[1:size(object_centroids,1)]';
props=input_args.Props.Value;
output_args.Tracks=[track_ids cur_time object_centroids props];

%end startTracks
end