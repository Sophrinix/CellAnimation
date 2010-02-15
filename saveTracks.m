function output_args=saveTracks(input_args)

tracks=input_args.Tracks.Value;
save(input_args.TracksFileName.Value,'tracks');
output_args=[];

%end saveTracks
end