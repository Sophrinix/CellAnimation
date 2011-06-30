function output_args=startTracksNoShapeProps(input_args)
%these are simple tracks - no shape properties
object_centroids=input_args.ObjectCentroids.Value;
cur_time=repmat((input_args.CurFrame.Value-1)*input_args.TimeFrame.Value,size(object_centroids,1),1);
track_ids=[1:size(object_centroids,1)]';
output_args.Tracks=[track_ids cur_time object_centroids];

%end startTracks
end