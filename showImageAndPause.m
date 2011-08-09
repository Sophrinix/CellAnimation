function output_args=showImageAndPause(input_args)
%Usage
%This module is used to show an image and pause execution.
%
%Input Structure Members
%FigureNr – The handle number of the MATLAB figure. If it doesn’t exist it will be created.
%Image – Matrix containing the image to be shown.
%
%Output Structure Members
%None.
%
%Example
%
%show_image_function.InstanceName=’ShowImage’;
%show_image_function.FunctionHandle=@showImageAndPause;
%show_image_function.FunctionArgs.FigureNr.Value=1;
%show_image_function.FunctionArgs.Image.FunctionInstance='AreaFilter';
%show_image_function.FunctionArgs.Image.OutputArg='LabelMatrix';

showmaxfigure(input_args.FigureNr.Value), imshow(input_args.Image.Value);
pause;
output_args=[];

end
