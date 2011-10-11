function output_args=loadTracksLayout(input_args)
%load the tracks layout file
load(input_args.FileName.Value);
output_args.TracksLayout=tracks_layout;

end