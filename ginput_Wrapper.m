function output_args=ginput_Wrapper(input_args)
%basic wrapper for the matlab ginput function
%Input Structure Members
%None
%Output Structure Members
%XYCoords - Array containing the coordinates returning by ginput.

output_args.XYCoords=ginput;

%end imadjust_Wrapper
end