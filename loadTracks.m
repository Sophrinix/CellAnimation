function output_args=loadTracks(input_args)
%load the tracks file
load(input_args.FileName.Value);
output_args.Tracks=tracks;

end