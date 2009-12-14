function [pol_1 pol_2] = splitPolygon(split_points, original_pol)
%assuming the last point is equal to first point in original_pol
%check that the potential split line is completely inside the polygon
max_points=round(max(abs(split_points(1,:)-split_points(2,:))));     
[cut_line_1 cut_line_2]=linepoints(split_points(1,:), split_points(2,:), max_points);
lines_inside_idx=inpolygon_custom(cut_line_1(:,2:max_points-1),cut_line_2(:,2:max_points-1),...
    original_pol(:,1),original_pol(:,2));
if (min(lines_inside_idx)==0)
    %line not inside
    pol_1=[];
    pol_2=[];
    return;
end
%for eps tolerance rank sometimes doesn't work to establish colinearity so
%use a larger tolerance rank_tol
rank_tol=0.00001;
%we need to figure out where these points are located so we know where to
%insert them in the list of points
%find out which points in the original polygon are colinear with my split points
%if i have 3 points p1 p2 p3 and rank ([p2-p1 ; p3-p1]) < 2 then the points
%are colinear. this is better than using det or cross as they are not
%as precise near zero. rank uses svd.
pol_len=size(original_pol,1);
start_point=split_points(1,:);
end_point=split_points(2,:);
%is the start point one of the vertices?
start_idx=find((start_point(:,1)==original_pol(1:end-1,1))&(start_point(:,2)==original_pol(1:end-1,2)));
if (isempty(start_idx))
    bStartIsVertex=false;
    %find the segment which will be split by our start point
    for i=1:pol_len-1
        if (rank([original_pol(i,:)-start_point; original_pol(i+1,:)-start_point],rank_tol)<2)
            %is the point inside the segment?
            if ((start_point(1,1)<min(original_pol(i:i+1,1)))||(start_point(1,1)>max(original_pol(i:i+1,1))))
                %colinear but not inside the segment
                continue;
            end
            if ((start_point(1,2)<min(original_pol(i:i+1,2)))||(start_point(1,2)>max(original_pol(i:i+1,2))))
                %colinear but not inside the segment
                continue;
            end
            %the start point is colinear with this segment - found the start point index
            start_idx=i;
            break;
        end
    end
else
    bStartIsVertex=true;
end

%is the end point one of the vertices?
end_idx=find((end_point(:,1)==original_pol(1:end-1,1))&(end_point(:,2)==original_pol(1:end-1,2)));
if (isempty(end_idx))
    %mark non-vertex
    bEndIsVertex=false;
    %find the segment which will be split by our end point
    for i=1:pol_len-1
        if (rank([original_pol(i,:)-end_point; original_pol(i+1,:)-end_point],rank_tol)<2)            
            %is the point inside the segment?            
            if ((end_point(1,1)<min(original_pol(i:i+1,1)))||(end_point(1,1)>max(original_pol(i:i+1,1))))
                %colinear but not inside the segment
                continue;
            end
            if ((end_point(1,2)<min(original_pol(i:i+1,2)))||(end_point(1,2)>max(original_pol(i:i+1,2))))
                %colinear but not inside the segment
                continue;
            end
            %the start point is colinear with this segment - found the end point index
            end_idx=i;
            break;
        end
    end
else
    bEndIsVertex=true;
end

bSwitchedStart=false;
if (start_idx>end_idx)
    bSwitchedStart=true;
    bTemp=bStartIsVertex;
    bStartIsVertex=bEndIsVertex;
    bEndIsVertex=bTemp;
    temp_idx=start_idx;    
    start_idx=end_idx;
    end_idx=temp_idx;
    start_point=split_points(2,:);
    end_point=split_points(1,:);    
end

if (bStartIsVertex)
    if (bEndIsVertex)
        pol_1=[original_pol(start_idx:end_idx,:); start_point];
    else
        %add the cut point after the end index
        pol_1=[original_pol(start_idx:end_idx,:); end_point; start_point];
    end
else
    if (bEndIsVertex)
        pol_1=[start_point; original_pol(start_idx+1:end_idx,:); start_point];
    else
        %add the cut point after the end index
        pol_1=[start_point; original_pol(start_idx+1:end_idx,:); end_point; start_point];
    end    
end

if (bEndIsVertex)
    %polygon 2 consists of the remaining points
    pol_2=original_pol(1:start_idx,:);
    if (~bStartIsVertex)
        %add the cut point
        pol_2=[pol_2; start_point];
    end    
    %and add from new_points_idx to end which is == beginning
    pol_2=[pol_2; original_pol(end_idx:end,:)];
else
    %polygon 2 consists of the remaining points
    pol_2=original_pol(1:start_idx,:);
    if (~bStartIsVertex)
        %add the cut point
        pol_2=[pol_2; start_point; end_point];
    else
        pol_2=[pol_2; end_point];
    end    
    %and add from new_points_idx to end which is == beginning
    pol_2=[pol_2; original_pol(end_idx+1:end,:)];
end

%polA should always contain the point after the first point in the split
%line
if (bSwitchedStart)
    pol_temp=pol_1;
    pol_1=pol_2;
    pol_2=pol_temp;    
end