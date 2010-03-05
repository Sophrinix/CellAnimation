function output_args=showImageAndPause(input_args)

showmaxfigure(input_args.FigureNr.Value), imshow(input_args.Image.Value);
pause;
output_args=[];

end