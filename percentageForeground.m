function output_args=percentageForeground(input_args)

img_bw=input_args.Image.Value;
img_sz=size(img_bw);
pct_fgd=sum(img_bw(:))/(img_sz(1)*img_sz(2));
output_args.PercentageForeground=pct_fgd;

end