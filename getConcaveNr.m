function [polA_concavities polB_concavities]=getConcaveNr(polA,polB,original_concave_points)
%return the minimum number of concavities left in either polygon
%first create linear indices so i can test the sets of points for
%intersections
max_vals=max([polA;polB;original_concave_points]);
polA_lin=sub2ind(max_vals,polA(:,1),polA(:,2));
polB_lin=sub2ind(max_vals,polB(:,1),polB(:,2));
original_concave_points_lin=sub2ind(max_vals,original_concave_points(:,1),original_concave_points(:,2));
%first find the split line - the split points will be common to both A and
%B
split_line_idx=ismember(polA_lin,polB_lin);
%eliminate those vertices from our search of concave elements since they
%have been converted to convex angles after splitting
convex_idx=ismember(original_concave_points_lin, polA_lin(split_line_idx));
original_concave_points_lin(convex_idx)=[];
%each point belong to the concave set of points will be marked with a 1
%otherwise 0
polA_idx=ismember(polA_lin,original_concave_points_lin);
polB_idx=ismember(polB_lin,original_concave_points_lin);
polA_concavities=sum(polA_idx);
polB_concavities=sum(polB_idx);