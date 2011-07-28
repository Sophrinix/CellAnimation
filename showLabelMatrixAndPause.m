function output_args=showLabelMatrixAndPause(input_args)
%Usage
%This module is used to show a MATLAB label matrix and pause execution.
%
%Input Structure Members
%FigureNr – The handle number of the MATLAB figure. If it doesn’t exist it will be created.
%LabelMatrix – The label matrix to be displayed.
%
%Output Structure Members
%None.
%
%Example
%
%show_image_function.InstanceName=’ShowLabel’;
%show_image_function.FunctionHandle=@ showLabelMatrixAndPause;
%show_image_function.FunctionArgs.FigureNr.Value=1;
%show_image_function.FunctionArgs. LabelMatrix.FunctionInstance='AreaFilter';
%show_image_function.FunctionArgs. LabelMatrix.OutputArg='LabelMatrix';

showmaxfigure(input_args.FigureNr.Value), imshow(label2rgb(input_args.LabelMatrix.Value));
pause;
output_args=[];

end
