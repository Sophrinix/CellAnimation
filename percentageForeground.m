function output_args=percentageForeground(input_args)
% Usage
% This module calculates the percentage of foreground pixels in a binary image.
% Input Structure Members
% Image – Binary image for which the percentage of foreground pixels is to be calculated.
% Output Structure Members
% PercentageForeground – The percentage of foreground pixels.

img_bw=input_args.Image.Value;
img_sz=size(img_bw);
pct_fgd=sum(img_bw(:))/(img_sz(1)*img_sz(2));
output_args.PercentageForeground=pct_fgd;

end
