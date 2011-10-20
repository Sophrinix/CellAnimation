function output_args=loadTracks(input_args)
%load the tracks file
% Input Structure Members
% FileName – The name of the data file containing the track data.
% 
% Output Structure Members
% Tracks – Matrix containing the  track data loaded from the file.
load(input_args.FileName.Value);
output_args.Tracks=tracks;

end