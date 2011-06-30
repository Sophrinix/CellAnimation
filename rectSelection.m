function output_args=rectSelection(input_args)

parent_handle=input_args.ParentHandle.Value;
region_handle=imrect(parent_handle,[]);
freehand_api=iptgetapi(region_handle);
position=freehand_api.getPosition();
output_args.XYPosition=position(1:2);
output_args.RectSize=position(3:4);

%end freehandSelection
end