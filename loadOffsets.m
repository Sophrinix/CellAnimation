function output_args=loadOffsets(input_args)
%load the offset data from file
% Input Structure Members
% FileName – The name of the data file containing the offset data.
% 
% Output Structure Members
% Offsets – The  offset data loaded from the file.

load(input_args.FileName.Value);
output_args.Offsets=xy_offsets;

%end loadOffsets
end