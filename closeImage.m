function output_args=closeImage(input_args)
%closeImage module
%close figure FigureNr

close(input_args.FigureNr.Value);
output_args=[];

end