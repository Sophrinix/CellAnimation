function output_args=getCurrentTracks(input_args)

%get tracks that existed in the previous max_missing_frames
tracks=input_args.Tracks.Value;
startframe=input_args.CurFrame.Value+input_args.OffsetFrame.Value;
timeframe=input_args.TimeFrame.Value;
timeCol=input_args.TimeCol.Value;
max_missing_frames=input_args.MaxMissingFrames.Value;
track_id_col=input_args.TrackIDCol.Value;
cur_tracks=tracks(tracks(:,timeCol)==(startframe-1)*timeframe,:);
track_ids=cur_tracks(:,track_id_col);
min_time=min(tracks(:,timeCol));
for i=1:max_missing_frames
    cur_time=(startframe-1-i)*timeframe;
    if (cur_time<min_time)
        break;
    end
    new_tracks_idx=tracks(:,timeCol)==cur_time;
    new_track_ids=tracks(new_tracks_idx,track_id_col);
    [diff_track_ids diff_track_idx]=setdiff(new_track_ids,track_ids);
    if isempty(diff_track_ids)
        continue;
    end
    new_tracks=tracks(new_tracks_idx,:);
    diff_tracks=new_tracks(diff_track_idx,:);
    cur_tracks=[cur_tracks; diff_tracks];
    track_ids=[track_ids; diff_track_ids];
end
output_args.Tracks=cur_tracks;
%end getCurrentTracks
end
