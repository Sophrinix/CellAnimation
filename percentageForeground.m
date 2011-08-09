function output_args=percentageForeground(input_args)
%Usage
%This module calculates the percentage of foreground pixels in a binary image.
%
%Input Structure Members
%Image – Binary image for which the percentage of foreground pixels is to be calculated.
%
%Output Structure Members
%PercentageForeground – The percentage of foreground pixels.
%
%Example
%
%percentage_foreground_function.InstanceName='PercentageForeground';
%percentage_foreground_function.FunctionHandle=@percentageForeground;
%percentage_foreground_function.FunctionArgs.Image.FunctionInstance='LabelToBW
%';
%percentage_foreground_function.FunctionArgs.Image.OutputArg='BooleanOut';
%
%functions_list=addToFunctionChain(functions_list,percentage_foreground_functi
%on);
%
%…
%
%display_cell_coverage_function.FunctionArgs.Variable.FunctionInstance='Percen
%tageForeground';
%display_cell_coverage_function.FunctionArgs.Variable.OutputArg='PercentageFor
%eground';

img_bw=input_args.Image.Value;
img_sz=size(img_bw);
pct_fgd=sum(img_bw(:))/(img_sz(1)*img_sz(2));
output_args.PercentageForeground=pct_fgd;

end
