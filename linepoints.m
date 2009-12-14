function [line_points_1 line_points_2]=linepoints(line_start_points, line_end_points, number_of_points)
%create a matrix which contains on each row an evenly spaced number_of_points belonging to
%the segment defined by each line_start-line_end pair
nr_lines=size(line_start_points,1);
line_points_1=zeros(nr_lines,number_of_points);
line_points_2=line_points_1;
slopes_diff_1=line_end_points(:,1)-line_start_points(:,1);
%check for infinite slope
infinite_slopes_idx=(slopes_diff_1==0);
line_slopes=(line_end_points(:,2)-line_start_points(:,2))./slopes_diff_1;
line_coeff=line_end_points(:,2)-line_slopes.*line_end_points(:,1);

%get the points for the first coordinate
line_points_1=linspacev(line_start_points(:,1)',line_end_points(:,1)',number_of_points);
%and calculate the points of the second coordinate
line_slopes_mat=repmat(line_slopes,1,number_of_points);
line_coeff_mat=repmat(line_coeff,1,number_of_points);
%if we have some infinite slopes need to fill the second coord values in
if (~isempty(find(infinite_slopes_idx,1)))
    infinite_slopes_idx_mat=repmat(infinite_slopes_idx,1,number_of_points);          
    %the value of the second coord is going to just be the evenly spaced
    %interval from start to end  
    line_points_2(infinite_slopes_idx_mat)=linspacev(line_start_points(infinite_slopes_idx,2)',line_end_points(infinite_slopes_idx,2)',number_of_points);
    %for all the non-infinite slope segments calculate the second coord
    %values using y=mx+b
    line_points_2(~infinite_slopes_idx_mat)=line_slopes_mat(~infinite_slopes_idx_mat).*line_points_1(~infinite_slopes_idx_mat)+line_coeff_mat(~infinite_slopes_idx_mat);    
else
    line_points_2=line_slopes_mat.*line_points_1+line_coeff_mat;    
end

end