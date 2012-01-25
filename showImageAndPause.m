function output_args=showImageAndPause(input_args)
% Usage
% This module is used to show an image and pause execution.
% Input Structure Members
% FigureNr – The handle number of the MATLAB figure. If it doesn’t exist it will be created.
% Image – Matrix containing the image to be shown.
% Output Structure Members
% None.


showmaxfigure(input_args.FigureNr.Value), imshow(input_args.Image.Value);
pause;
output_args=[];

end
