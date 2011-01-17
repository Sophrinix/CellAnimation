function checkerboard_pattern=createCheckerBoardPattern(selected_object)

cur_obj_size=sum(selected_object(:));
checkerboard_pattern=repmat([0;intmax('uint8')],floor(cur_obj_size/2),1);
if (rem(cur_obj_size,2))
    checkerboard_pattern=[checkerboard_pattern;0];  
end
checkerboard_pattern=repmat(checkerboard_pattern,3,1);

%end createCheckerBoardPattern
end