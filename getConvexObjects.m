function convex_objects_idx=getConvexObjects(img_cells, pol_simplify)
%assumes the index of the boundaries is the same as the label index
%bwboundaries uses bwlabel internally then calls bwboundariesmex on the
%label image so it all works out
obj_bounds=bwboundaries(img_cells);
obj_nr=length(obj_bounds);
convex_objects_idx=false(obj_nr,1);

for i=1:obj_nr    
    cur_bound=obj_bounds{i};
    pol_points_1=dpsimplify([cur_bound(:,1) cur_bound(:,2)],pol_simplify);
    %to get the angles inside the polygon we need to create vectors that
    %have as base each vertex and as end the next and previous vertice and
    %then translate their base to the origin. because we need each vertex
    %as a base twice we traverse the polygon in both directions
    pol_points_2=flipud(pol_points_1);
    %now get the vectors
    pol_vect_1=diff(pol_points_1);
    pol_vect_2=diff(pol_points_2);
    pol_len=length(pol_vect_1);    
    if (pol_len==3)
        %a triangle is a convex polygon
        convex_objects_idx(i)=true;
        continue;
    end    
    %index to match the coord of pol_dist_2 to pol_dist_1
    pol_idx_2=pol_len-[1:pol_len-1]+1;
    %element 1 of pol_vect_1 matches with element 1 of pol_vect_2 ie if you
    %have 123451 and 154321 1 matches 1 but the rest have to be matched
    pol_idx_2=[1 pol_idx_2];
    %now match them
    pol_vect_2(:,1)=pol_vect_2(pol_idx_2,1);
    pol_vect_2(:,2)=pol_vect_2(pol_idx_2,2);
    u2=pol_vect_1(:,1);
    u1=pol_vect_2(:,1);
    v2=pol_vect_1(:,2);
    v1=pol_vect_2(:,2);
    % Assuming a = [x1,y1] and b = [x2,y2] are two vectors with their bases at the
    % origin, the non-negative angle between them measured counterclockwise from a to b is given by
    %pol_angles=mod(atan2(x1*y2-x2*y1,x1*x2+y1*y2),2*pi);
    %dot product gives cos and cross product gives sin
    %the angle measured on the outside is 2*pi-angle measured on the inside
    %of the polygon
    outside_angles=2*pi-mod(atan2(u1.*v2-u2.*v1,u1.*u2+v1.*v2),2*pi);
    %get the convex angles where we might cut
    concave_idx=find(outside_angles<pi,1);    
    if (isempty(concave_idx))
        %convex polygon - no concave angles
        convex_objects_idx(i)=true;
    end
end