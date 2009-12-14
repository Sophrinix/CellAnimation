function structSplitLine = findSplitLines(convex_points, degrees_sorted, origin_idx, pol_opposite, pol_original, min_area)
%this function returns a structure which has the following fields
% endpoint endpoint_degree pol_1 pol_2 structCost
structSplitLine=[];
origin_point=convex_points(origin_idx,:);
origin_degree=degrees_sorted(origin_idx);
if (origin_degree<2)
    return;
end
convex_points_len=size(convex_points,1);
other_points_idx=ones(convex_points_len,1);
other_points_idx(origin_idx)=0;
other_points_idx=logical(other_points_idx);
other_points=convex_points(other_points_idx,:);
other_degrees=degrees_sorted(other_points_idx);
%opposite side constraint
%make linear indices so we have a unique set of identifiers which we can
%use with ismember
max_vals=max([pol_opposite; convex_points]);
opposite_lin=sub2ind(max_vals,pol_opposite(:,1),pol_opposite(:,2));
other_points_lin=sub2ind(max_vals,other_points(:,1),other_points(:,2));
%remove the origin point from this list
potential_end_points_idx=ismember(other_points_lin,opposite_lin);
%need to go through all others convex_points since for example angle 3 might not be
%in the opposite pol of angle 1 but angle 1 might be in the opposite pol of
%angle 3. so a 1-3 pairing might not exist but a 3-1 pairing will.
potential_end_points=other_points(potential_end_points_idx,:);
potential_degrees=other_degrees(potential_end_points_idx);
pot_len=size(potential_end_points,1);
if (pot_len==0)
    if (origin_degree>2)
        [end_point polA polB]=findMaxAreaRatio(pol_original,origin_point);
        if(isempty(end_point))
            return;
        end
        if ((polyarea(polA(:,1),polA(:,2))<min_area)||(polyarea(polB(:,1),polB(:,2))<min_area))
            structSplitLine=[];
            return;
        end
        splitLine.startPoint=origin_point;
        splitLine.startDegree=origin_degree;
        splitLine.endPoint=end_point;
        splitLine.endDegree=0;        
        splitLine.polA=polA;
        splitLine.polB=polB;
        testVals=addTestValues(splitLine, convex_points);
        splitLine.tests=testVals;
        structSplitLine=splitLine;
    else
        structSplitLine=[];
    end
else    
    for i=1:pot_len
        max_points=ceil(max(abs(origin_point-potential_end_points(i,:))));        
        %make sure a line connecting the two points is completely inside the opposite sides polygon
        [cut_line_1 cut_line_2]=linepoints(origin_point, potential_end_points(i,:), max_points);
        lines_inside_idx=inpolygon_custom(cut_line_1(:,2:max_points-1),cut_line_2(:,2:max_points-1),...
            pol_opposite(:,1),pol_opposite(:,2));
        if (min(lines_inside_idx)==0)
            %line not inside
            continue;
        end          
        [polA polB]=splitPolygon([origin_point; potential_end_points(i,:)] , pol_original);
        
        if ((polyarea(polA(:,1),polA(:,2))<min_area)||(polyarea(polB(:,1),polB(:,2))<min_area))
            %resulting polygons need to be above a certain area threshold
            continue;
        end
        splitLine.startPoint=origin_point;
        splitLine.startDegree=origin_degree;
        splitLine.endPoint=potential_end_points(i,:);
        splitLine.endDegree=potential_degrees(i);
        splitLine.polA=polA;
        splitLine.polB=polB;
        %add the values of the test appropriate for this start-end
        %convexity degrees
        testVals=addTestValues(splitLine, convex_points);
        splitLine.tests=testVals;
        structSplitLine=[structSplitLine;splitLine];
    end
end