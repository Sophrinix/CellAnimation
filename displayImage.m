function output_args=displayImage(input_args)

showmaxfigure(input_args.FigureNr.Value), imshow(input_args.Image.Value);
output_args=[];

end