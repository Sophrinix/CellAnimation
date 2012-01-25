function output_args=rectSelection(input_args)
%simple wrapper for MATLAB imrect function.
%Input Structure Members
%ParentHandle - Handle to the image where the freehand region will be
%drawn.
%Output Structure Members
%XYPosition - The xmin,ymin coordinates of the rectangle.
%RectSize - The width and height of the rectangle.

parent_handle=input_args.ParentHandle.Value;
region_handle=imrect(parent_handle,[]);
freehand_api=iptgetapi(region_handle);
position=freehand_api.getPosition();
output_args.XYPosition=position(1:2);
output_args.RectSize=position(3:4);

%end freehandSelection
end