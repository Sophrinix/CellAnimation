function output_args=freehandSelection(input_args)
%simple wrapper for MATLAB imfreehand function.
%Input Structure Members
%ParentHandle - Handle to the image where the freehand region will be
%drawn.
%Output Structure Members
%RegionPixels - Array containing the selected pixels.

parent_handle=input_args.ParentHandle.Value;
region_handle=imfreehand(parent_handle);
freehand_api=iptgetapi(region_handle);
output_args.RegionPixels=freehand_api.getPosition();

%end freehandSelection
end