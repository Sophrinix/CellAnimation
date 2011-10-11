function output_args=loadColormap(input_args)
%load the colormap used to generate the overlayed cells outlines
load(input_args.FileName.Value);
output_args.Colormap=cmap;

end