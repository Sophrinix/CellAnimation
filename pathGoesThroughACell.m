function b_path_goes_through_a_cell=pathGoesThroughACell(cells_lbl, prev_cells_lbl, cur_id, prev_id, bkg_id)
cur_pxls=cells_lbl==cur_id;
prev_pxls=prev_cells_lbl==prev_id;
and_pxls=cur_pxls&prev_pxls;
if (max(and_pxls(:)==1))
    %the current and previous positions overlap to some extent
    b_path_goes_through_a_cell=false;
    return;
end
%the positions do not overlap get the perimeter pixels
%crop the boxes otherwise bwboundaries will be really slow
[cur_pxls_1 cur_pxls_2]=find(cur_pxls);
[prev_pxls_1 prev_pxls_2]=find(prev_pxls);
min_1=min([cur_pxls_1; prev_pxls_1]);
max_1=max([cur_pxls_1; prev_pxls_1]);
min_2=min([cur_pxls_2; prev_pxls_2]);
max_2=max([cur_pxls_2; prev_pxls_2]);
cur_pxls=cur_pxls(min_1:max_1,min_2:max_2);
prev_pxls=prev_pxls(min_1:max_1,min_2:max_2);
cur_perim_pixels=bwboundaries(cur_pxls,'noholes');
cur_perim_pixels=cur_perim_pixels{1};
prev_perim_pixels=bwboundaries(prev_pxls,'noholes');
prev_perim_pixels=prev_perim_pixels{1};
cur_points_nr=size(cur_perim_pixels,1);
prev_points_nr=size(prev_perim_pixels,1);
%compute the pairwise distance matrix between the two sets of points
distance_matrix=zeros(cur_points_nr,prev_points_nr);
for i=1:cur_points_nr
    point_mat=repmat(cur_perim_pixels(i,:),prev_points_nr,1);
    distance_matrix(i,:)=hypot(prev_perim_pixels(:,1)-point_mat(:,1),prev_perim_pixels(:,2)-point_mat(:,2));
end
min_val=min(distance_matrix(:));
[cur_point_idx prev_point_idx]=find(distance_matrix==min_val,1);
closest_cur_point=cur_perim_pixels(cur_point_idx,:)+[min_1 min_2];
closest_prev_point=prev_perim_pixels(prev_point_idx,:)+[min_1 min_2];
coord_1_len=abs(closest_cur_point(1)-closest_prev_point(1));
coord_2_len=abs(closest_cur_point(2)-closest_prev_point(2));
if (coord_1_len>coord_2_len)
    if (closest_cur_point(1)>closest_prev_point(1))
        coord_1=round([closest_prev_point(1) closest_cur_point(1)]);
        coord_2=round([closest_prev_point(2) closest_cur_point(2)]);
    else
        coord_1=round([closest_cur_point(1) closest_prev_point(1)]);
        coord_2=round([closest_cur_point(2) closest_prev_point(2)]);
    end
    coord_1_interp=coord_1(1):coord_1(2);
    coord_2_interp=round(interp1q(coord_1',coord_2',coord_1_interp')');
else
    if (closest_cur_point(2)>closest_prev_point(2))
        coord_1=round([closest_prev_point(1) closest_cur_point(1)]);
        coord_2=round([closest_prev_point(2) closest_cur_point(2)]);
    else
        coord_1=round([closest_cur_point(1) closest_prev_point(1)]);
        coord_2=round([closest_cur_point(2) closest_prev_point(2)]);
    end
    coord_2_interp=coord_2(1):coord_2(2);
    coord_1_interp=round(interp1q(coord_2',coord_1',coord_2_interp')');
end
img_sz=size(cells_lbl);
coord_lin=sub2ind(img_sz,coord_1_interp,coord_2_interp);
lbl_ids=unique(prev_cells_lbl(coord_lin));
lbl_ids(lbl_ids==prev_id)=[];
lbl_ids(lbl_ids==bkg_id)=[];
b_path_goes_through_a_cell=~isempty(lbl_ids);

%end pathGoesThroughACell
end