function output_args=getCurrentTracks(input_args)
%module to get the tracks that existed in the previous max_missing_frames
tracks=input_args.Tracks.Value;
frame_step=input_args.FrameStep.Value;
offset_frame=input_args.OffsetFrame.Value;
startframe=input_args.CurFrame.Value+frame_step*offset_frame;
offset_dir=sign(offset_frame);
timeframe=input_args.TimeFrame.Value;
timeCol=input_args.TimeCol.Value;
max_missing_frames=input_args.MaxMissingFrames.Value;
track_id_col=input_args.TrackIDCol.Value;
cur_tracks=tracks(tracks(:,timeCol)==(startframe-1)*timeframe,:);
track_ids=cur_tracks(:,track_id_col);
min_time=min(tracks(:,timeCol));
for i=frame_step:frame_step:(frame_step*max_missing_frames)
    cur_time=(startframe+offset_dir*i-1)*timeframe;
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
