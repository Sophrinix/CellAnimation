function output_args=freehandSelection(input_args)

parent_handle=input_args.ParentHandle.Value;
region_handle=imfreehand(parent_handle);
freehand_api=iptgetapi(region_handle);
output_args.RegionPixels=freehand_api.getPosition();

%end freehandSelection
end