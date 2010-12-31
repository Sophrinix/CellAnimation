function track_ranks=rankParams(cur_shape_params,nearby_shape_params)
%helper function for CA tracking algorithm. rank how similar each previous nearby cell is to the current cell
[nr_tracks nr_params]=size(nearby_shape_params);
track_ranks=zeros(nr_tracks, nr_params);

for i=1:nr_params
    diff_from_cur_param=abs(cur_shape_params(:,i)-nearby_shape_params(:,i));
    [dummy param_rank]=sort(diff_from_cur_param);
    equal_vals_idx=~diff(diff_from_cur_param);
    replace_ranks_idx=[false; equal_vals_idx];
    replace_vals_idx=[equal_vals_idx; false];
    param_rank(replace_ranks_idx)=param_rank(replace_vals_idx);    
    track_ranks(:,i)=param_rank;
end
%end rankParams
end