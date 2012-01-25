function output_args=imageFromRegion(input_args)
%create a binary image setting the region as foreground
%Input Structure Members
%ImageSize - The size of the image to be created.
%RegionPixels - Array containing the list of pixels in region.
%Output Structure Members
%Image - The mask image.
img_sz=input_args.ImageSize.Value;
fgnd=round(input_args.RegionPixels.Value);
mask=poly2mask(fgnd(:,1),fgnd(:,2),img_sz(1),img_sz(2));
output_args.Image=repmat(mask,[1 1 img_sz(3)]);

%end imageFromRegion
end