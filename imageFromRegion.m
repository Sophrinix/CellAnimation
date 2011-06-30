function output_args=imageFromRegion(input_args)
%create a binary image setting the region as foreground
img_sz=input_args.ImageSize.Value;
fgnd=round(input_args.RegionPixels.Value);
mask=poly2mask(fgnd(:,1),fgnd(:,2),img_sz(1),img_sz(2));
output_args.Image=repmat(mask,[1 1 img_sz(3)]);

%end imageFromRegion
end