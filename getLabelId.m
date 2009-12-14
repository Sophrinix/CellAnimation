function lbl_id=getLabelId(cells_lbl, cell_centroid)
%main reason for this function is that the centroid may fall outside the
%cell body
lbl_id=0;
xtend_sz=0;
cell_coord=round(cell_centroid);
while(lbl_id==0)
    min_1=cell_coord(1)-xtend_sz;
    max_1=cell_coord(1)+xtend_sz;
    min_2=cell_coord(2)-xtend_sz;
    max_2=cell_coord(2)+xtend_sz;
    lbl_vals=cells_lbl(min_1:max_1,min_2:max_2);
    lbl_vals=lbl_vals(:);
    lbl_vals(lbl_vals==0)=[];
    if (isempty(lbl_vals))
        xtend_sz=xtend_sz+1;
    else
        lbl_id=median(lbl_vals);
    end
end

%end getLabelID
end