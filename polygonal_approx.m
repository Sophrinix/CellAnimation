function [split_polygons lbl_id]=polygonal_approx(img_cells, cells_lbl, min_polygon_area, pol_simplify,...
    l1,l2,l3,alpha1,alpha2,bRemoveLongSplits, bConvexOnly)
img_sz=size(img_cells);
split_polygons=[];
lbl_id=[];
%polygonal approx - start
obj_bounds=bwboundaries(img_cells,'noholes');
obj_nr=length(obj_bounds);
polygons_list={};
% approximate the cell contours using polynomials. split selfintersecting
% polynomials into separate distinct polynomials
% showmaxfigure(1), imshow(img_cells)
% hold on

for i=1:obj_nr    
    cur_bound=obj_bounds{i};
    pol_points_1=dpsimplify([cur_bound(:,1) cur_bound(:,2)],pol_simplify);
    pols_split=splitSelfIntersectPolygon(pol_points_1);    
    for j=1:length(pols_split)        
        pol_cur=pols_split{j};
%         plot(pol_cur(:,2),pol_cur(:,1))
%         text(pol_cur(1,2),pol_cur(1,1),num2str(i),'color','g');
        if (polyarea(pol_cur(:,1),pol_cur(:,2))<min_polygon_area)
            %discard resulting polygons which are smaller than our current
            %threshold
%             plot(pol_cur(:,2),pol_cur(:,1),'r')
            continue;
        else
%             plot(pol_cur(:,2),pol_cur(:,1),'b')
        end
        polygons_list=[polygons_list;pols_split{j}];
    end    
end

% showmaxfigure(1), imshow(img_cells)
% hold on
% showmaxfigure(2), imshow(img_to_proc_norm)
% hold on

% keep processing polygons until they are all convex or can't be split
% further with the restrictions imposed by the current cost functions
blob_id=[];
processed_polygons={};
polygons_to_process={};
while (~isempty(polygons_list))    
    obj_nr=size(polygons_list,1);    
    for i=1:obj_nr        
        pol_points_1=polygons_list{i};
        %to get the angles inside the polygon we need to create vectors that
        %have as base each vertex and as end the next and previous vertice and
        %then translate their base to the origin. because we need each vertex
        %as a base twice we traverse the polygon in both directions
        pol_points_2=flipud(pol_points_1);
        %now get the vectors
        pol_vect_1=diff(pol_points_1);
        pol_vect_2=diff(pol_points_2);
        pol_len=length(pol_vect_1);
        %a triangle doesn't have convex outside angles since angles inside it
        %have to add up to 180
%         figure(1),plot(pol_points_1(:,2),pol_points_1(:,1))
%         figure(2),plot(pol_points_1(:,2),pol_points_1(:,1))
        if (pol_len==3)            
            cur_pol=polygons_list{i};
            processed_polygons=[processed_polygons;cur_pol];
            cur_pol_lin=sub2ind(img_sz,round(cur_pol(:,1)),round(cur_pol(:,2)));                
            cur_blob_id=max(cells_lbl(cur_pol_lin));
            assert(cur_blob_id>0,'Blob id is zero!');
            blob_id=[blob_id; cur_blob_id];
            continue;
        end
%         figure(1),plot(pol_points_1(:,2),pol_points_1(:,1))
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
        convex_idx=find(outside_angles<pi);
        points_len=length(convex_idx);
        %add a constraint based on the length of each segment forming the angle
        %here
        %no convex angles no cut
        if (isempty(convex_idx))
            cur_pol=polygons_list{i};
            processed_polygons=[processed_polygons;cur_pol];
            cur_pol_lin=sub2ind(img_sz,round(cur_pol(:,1)),round(cur_pol(:,2)));                
            cur_blob_id=max(cells_lbl(cur_pol_lin));
            assert(cur_blob_id>0,'Blob id is zero!');
            blob_id=[blob_id; cur_blob_id];
            continue;
        end
        
        if (bConvexOnly)
            continue;
        end
        %get the points forming the angle
        convex_idx_eq_1=convex_idx==1;
        points_a_1=zeros(points_len,1);
        points_a_2=points_a_1;
        points_b_1=points_a_1;
        points_b_2=points_a_1;
        points_a_1(convex_idx_eq_1)=pol_points_1(points_len,1);
        points_a_2(convex_idx_eq_1)=pol_points_1(points_len,2);
        points_a_1(~convex_idx_eq_1)=pol_points_1(convex_idx(~convex_idx_eq_1)-1,1);
        points_a_2(~convex_idx_eq_1)=pol_points_1(convex_idx(~convex_idx_eq_1)-1,2);

        points_o_1=pol_points_1(convex_idx,1);
        points_o_2=pol_points_1(convex_idx,2);

        convex_idx_eq_end=convex_idx==pol_len;
        points_b_1(convex_idx_eq_end)=pol_points_1(1,1);
        points_b_2(convex_idx_eq_end)=pol_points_1(1,2);
        points_b_1(~convex_idx_eq_end)=pol_points_1(convex_idx(~convex_idx_eq_end)+1,1);
        points_b_2(~convex_idx_eq_end)=pol_points_1(convex_idx(~convex_idx_eq_end)+1,2);


        %classify points based on angle and sides length
        %see binary image segmentation of aggregates based on polygonal
        %approximation... - w x wang
        point_degrees=zeros(size(points_o_1,1),1);
%         l1=10;
%         l3=10;
%         l2=0.6;
        ao_len=sqrt((points_o_1-points_a_1).^2+(points_o_2-points_a_2).^2);
        bo_len=sqrt((points_o_1-points_b_1).^2+(points_o_2-points_b_2).^2);
        l_max=max([ao_len bo_len],[],2);
        l_diff=abs(ao_len-bo_len)./l_max;
        greater_than_l1_idx=l_max>l1;
        greater_than_l3_idx=l_max>l3;
        greater_than_l2_idx=l_diff>l2;
%         alpha1=5*pi/6;
%         alpha2=pi/2;
        convex_angles=outside_angles(convex_idx);
        greater_than_alpha1_idx=convex_angles>alpha1;
        greater_than_alpha2_idx=convex_angles>alpha2;
        %now assign the point degrees
        % pi>alpha>alpha1
        point_degrees(greater_than_alpha1_idx)=1;
        %alpha1>=alpha>alpha2 and lmax<=l1
        point_degrees((~greater_than_alpha1_idx) & greater_than_alpha2_idx & (~greater_than_l1_idx))=2;
        %alpha1>=alpha>alpha2 and lmax>l1 and l_diff>l2
        point_degrees((~greater_than_alpha1_idx) & greater_than_alpha2_idx...
            & greater_than_l1_idx & greater_than_l2_idx)=2;
        %alpha1>=alpha>alpha2 and lmax>l1 and l_diff<=l2
        point_degrees((~greater_than_alpha1_idx) & greater_than_alpha2_idx...
            & greater_than_l1_idx & (~greater_than_l2_idx))=3;
        %alpha<=alpha2 and lmax<=l3
        point_degrees((~greater_than_alpha2_idx)&(~greater_than_l3_idx))=2;
        %alpha<=alpha2 and lmax>l3
        point_degrees((~greater_than_alpha2_idx)& greater_than_l3_idx)=4;

        [degrees_sorted degrees_sort_idx]=sort(point_degrees);
        %now sort the points by degree of concavity
        points_o_1=points_o_1(degrees_sort_idx);
        points_o_2=points_o_2(degrees_sort_idx);
        points_a_1=points_a_1(degrees_sort_idx);
        points_a_2=points_a_2(degrees_sort_idx);
        points_b_1=points_b_1(degrees_sort_idx);
        points_b_2=points_b_2(degrees_sort_idx);
        convex_idx=convex_idx(degrees_sort_idx);
        %     convex_angles=convex_angles(degrees_sort_idx);

        %extend lines forming the angle to get a triangular area on the opposite side in which we
        %might cut
        dist_ext=400;


        %first the ao segment
        %calculate the equations for all the ao segments
        slope_ao=(points_a_2-points_o_2)./(points_a_1-points_o_1);
        coeff_ao=points_a_2-slope_ao.*points_a_1;
        %when building the lines we have a few cases to consider o1 greater
        %than a1, smaller than a1 or equal to a1 (infinite slope)
        o_1_greater_idx=points_o_1>points_a_1;
        o_1_smaller_idx=points_o_1<points_a_1;
        o_1_equal_idx=points_o_1==points_a_1;
        %create the start and end segments
        lines_ao_1_start=zeros(points_len,1);
        lines_ao_1_end=lines_ao_1_start;
        lines_ao_2_start=lines_ao_1_start;
        lines_ao_2_end=lines_ao_1_start;
        %calculate the start and end first coordinates for the lines where o_1>a_1
        lines_ao_1_start(o_1_greater_idx)=points_o_1(o_1_greater_idx)+1;
        lines_ao_1_end(o_1_greater_idx)=lines_ao_1_start(o_1_greater_idx)+dist_ext;
        %calculate the start and end first coordinates for the lines where o_1<a_1
        lines_ao_1_start(o_1_smaller_idx)=points_o_1(o_1_smaller_idx)-1;
        lines_ao_1_end(o_1_smaller_idx)=lines_ao_1_start(o_1_smaller_idx)-dist_ext;

        %as long as the slope is not infinite the second coordinates are calculated in the
        %same manner
        lines_ao_2_start(~o_1_equal_idx)=slope_ao(~o_1_equal_idx).*lines_ao_1_start(~o_1_equal_idx)+coeff_ao(~o_1_equal_idx);
        lines_ao_2_end(~o_1_equal_idx)=slope_ao(~o_1_equal_idx).*lines_ao_1_end(~o_1_equal_idx)+coeff_ao(~o_1_equal_idx);

        %i might have some infinite slopes
        if (max(o_1_equal_idx)==1)
            o_2_greater_idx=points_o_2>points_a_2;
            o_2_smaller_idx=points_o_2<points_a_2;
            %if the slope is infinite the start and end first coordinates are
            %the same
            lines_ao_1_start(o_1_equal_idx)=points_o_1(o_1_equal_idx);
            lines_ao_1_end(o_1_equal_idx)=lines_ao_1_start(o_1_equal_idx);
            %if the slope is infinite the y coord will be just a linearly spaced
            %vector from o_2 to a_2
            lines_ao_2_start(o_1_equal_idx & o_2_greater_idx)=points_o_2(o_1_equal_idx & o_2_greater_idx)+1;
            lines_ao_2_end(o_1_equal_idx & o_2_greater_idx)=lines_ao_2_start(o_1_equal_idx & o_2_greater_idx)+dist_ext;
            lines_ao_2_start(o_1_equal_idx & o_2_smaller_idx)=points_o_2(o_1_equal_idx & o_2_smaller_idx)-1;
            lines_ao_2_end(o_1_equal_idx & o_2_smaller_idx)=lines_ao_2_start(o_1_equal_idx & o_2_smaller_idx)-dist_ext;
        end




        %now the the bo segments
        %calculate the equations for all the bo segments
        slope_bo=(points_b_2-points_o_2)./(points_b_1-points_o_1);
        coeff_bo=points_b_2-slope_bo.*points_b_1;
        %when building the lines we have a few cases to consider o1 greater
        %than a1, smaller than a1 or equal to a1 (infinite slope)
        o_1_greater_idx=points_o_1>points_b_1;
        o_1_smaller_idx=points_o_1<points_b_1;
        o_1_equal_idx=points_o_1==points_b_1;
        %create the start and end segments
        lines_bo_1_start=zeros(points_len,1);
        lines_bo_1_end=lines_bo_1_start;
        lines_bo_2_start=lines_bo_1_start;
        lines_bo_2_end=lines_bo_1_start;
        %calculate the start and end first coordinates for the lines where o_1>a_1
        lines_bo_1_start(o_1_greater_idx)=points_o_1(o_1_greater_idx)+1;
        lines_bo_1_end(o_1_greater_idx)=lines_bo_1_start(o_1_greater_idx)+dist_ext;
        %calculate the start and end first coordinates for the lines where o_1<a_1
        lines_bo_1_start(o_1_smaller_idx)=points_o_1(o_1_smaller_idx)-1;
        lines_bo_1_end(o_1_smaller_idx)=lines_bo_1_start(o_1_smaller_idx)-dist_ext;

        %as long as the slope is not infinite the second coordinates are calculated in the
        %same manner
        lines_bo_2_start(~o_1_equal_idx)=slope_bo(~o_1_equal_idx).*lines_bo_1_start(~o_1_equal_idx)+coeff_bo(~o_1_equal_idx);
        lines_bo_2_end(~o_1_equal_idx)=slope_bo(~o_1_equal_idx).*lines_bo_1_end(~o_1_equal_idx)+coeff_bo(~o_1_equal_idx);

        %i might have some infinite slopes
        if (max(o_1_equal_idx)==1)
            o_2_greater_idx=points_o_2>points_b_2;
            o_2_smaller_idx=points_o_2<points_b_2;
            %if the slope is infinite the start and end first coordinates are
            %the same
            lines_bo_1_start(o_1_equal_idx)=points_o_1(o_1_equal_idx);
            lines_bo_1_end(o_1_equal_idx)=lines_bo_1_start(o_1_equal_idx);
            %if the slope is infinite the y coord will be just a linearly spaced
            %vector from o_2 to a_2
            lines_bo_2_start(o_1_equal_idx & o_2_greater_idx)=points_o_2(o_1_equal_idx & o_2_greater_idx)+1;
            lines_bo_2_end(o_1_equal_idx & o_2_greater_idx)=lines_bo_2_start(o_1_equal_idx & o_2_greater_idx)+dist_ext;
            lines_bo_2_start(o_1_equal_idx & o_2_smaller_idx)=points_o_2(o_1_equal_idx & o_2_smaller_idx)-1;
            lines_bo_2_end(o_1_equal_idx & o_2_smaller_idx)=lines_bo_2_start(o_1_equal_idx & o_2_smaller_idx)-dist_ext;
        end


        %minimum perimeter of the two resulting polygons for which i will accept a cut
        %min_perim=130;


        splitLines=[];
        %get the potential split polygons if any
        
        for j=1:points_len

            %create a polygon containing the opposite sides
            pol_opp=[points_o_1(j) points_o_2(j); lines_ao_1_end(j) lines_ao_2_end(j); lines_bo_1_end(j) lines_bo_2_end(j); points_o_1(j) points_o_2(j)];
            %create a roi for split points which consists of the intersection
            %of pol_opp with the cell polygon
            [roi_split_1 roi_split_2]=polybool('and',pol_opp(:,1),pol_opp(:,2),pol_points_1(:,1),pol_points_1(:,2));
            if (isempty(roi_split_1))
%                 figure(1),plot(pol_points_1(:,2),pol_points_1(:,1),'r')
%                 figure(2),plot(pol_points_1(:,2),pol_points_1(:,1),'r')
                continue;
            end

            %check if there is a duplicate point returned by polybool - it
            %sometimes does that
            dupl_point_idx=(roi_split_1==circshift(roi_split_1,1))&(roi_split_2==circshift(roi_split_2,1));
            %i know the first and last are duplicates
            dupl_point_idx(1)=0;
            %any other duplicates have to be removed
            roi_split_1(dupl_point_idx)=[];
            roi_split_2(dupl_point_idx)=[];
            %keep a copy of the polygon intact for some later processing
            pol_split_1=roi_split_1;
            pol_split_2=roi_split_2;

            %get all the possible split lines from the current point to the
            %opposite side
            curSplitLines=findSplitLines([points_o_1 points_o_2],degrees_sorted,j,[pol_split_1 pol_split_2],...
                pol_points_1, min_polygon_area);
            
            %add the current split line candidates to the list of all
            %possible split lines
            splitLines=[splitLines;curSplitLines];
            
%             figure(1),plot([points_o_2(j);end_point(1,2)],[points_o_1(j);end_point(1,1)],'r')
%             figure(2),plot([points_o_2(j);end_point(1,2)],[points_o_1(j);end_point(1,1)],'r')
            
        end
        
        splitLine=pickSplitLine(splitLines,bRemoveLongSplits);
        if (isempty(splitLine))
            %add any polygons that can't be split further to the processed
            %list
            cur_pol=polygons_list{i};
            processed_polygons=[processed_polygons;cur_pol];
            cur_pol_lin=sub2ind(img_sz,round(cur_pol(:,1)),round(cur_pol(:,2)));                
            cur_blob_id=max(cells_lbl(cur_pol_lin));
            assert(cur_blob_id>0,'Blob id is zero!');
            blob_id=[blob_id; cur_blob_id];
            continue;
        end        
        
        tests=splitLine.tests;
        concavitiesA=[tests.concavitiesA];
        concavitiesB=[tests.concavitiesB];
        if(concavitiesA==0)
            polA=splitLine.polA;
            processed_polygons=[processed_polygons;polA];
            polA_lin=sub2ind(img_sz,round(polA(:,1)),round(polA(:,2)));
            cur_blob_id=max(cells_lbl(polA_lin));
            assert(cur_blob_id>0,'Blob id is zero!');
            blob_id=[blob_id; cur_blob_id];
        else
            polygons_to_process=[polygons_to_process;splitLine.polA];
        end
        if(concavitiesB==0)
            polB=splitLine.polB;
            processed_polygons=[processed_polygons;polB];
            polB_lin=sub2ind(img_sz,round(polB(:,1)),round(polB(:,2)));
            cur_blob_id=max(cells_lbl(polB_lin));
            assert(cur_blob_id>0,'Blob id is zero!');
            blob_id=[blob_id; cur_blob_id];
        else
            polygons_to_process=[polygons_to_process;splitLine.polB];
        end
        end_point=splitLine.endPoint;

    end
    polygons_list=polygons_to_process;
    polygons_to_process={};
end

lbl_id=blob_id;
if (bConvexOnly)
    %only need to collect the list of already convex polygons no splitting
    return;
end
split_polygons=processed_polygons;
%end function
end