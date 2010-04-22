function output_args=showLabelMatrixAndPause(input_args)

showmaxfigure(input_args.FigureNr.Value), imshow(label2rgb(input_args.LabelMatrix.Value));
pause;
output_args=[];

end