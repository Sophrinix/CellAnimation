function output_args=loadColormap(input_args)
%load the colormap used to generate the overlayed cells outlines
% Input Structure Members
% FileName – The name of the data file containing the colormap data.
% 
% Output Structure Members
% Colormap – The  colormap data loaded from the file.
load(input_args.FileName.Value);
output_args.Colormap=cmap;

end