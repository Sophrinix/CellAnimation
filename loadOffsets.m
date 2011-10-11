function output_args=loadOffsets(input_args)
%load the ancestry file

load(input_args.FileName.Value);
output_args.Offsets=xy_offsets;

%end loadOffsets
end