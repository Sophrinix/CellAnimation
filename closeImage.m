function output_args=closeImage(input_args)
% Simple wrapper for MATLAB close function
% Input Members
% FigureNr - the figure number to be closed

close(input_args.FigureNr.Value);
output_args=[];

end