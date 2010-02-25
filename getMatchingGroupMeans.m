function output_args=getMatchingGroupMeans(input_args)
%get the mean param values for each matching group
tracks=input_args.Tracks.Value;
tracks_layout=input_args.TracksLayout.Value;
group_id_col=tracks_layout.MatchGroupIDCol;
start_params_col=tracks_layout.AreaCol;
end_params_col=tracks_layout.SolCol;

tracks_no_zeroth_group=tracks(tracks(:,group_id_col)~=0,:);
if (isempty(tracks_no_zeroth_group))
    output_args.MatchingGroupStats=[];
    return;
end
group_ids=tracks_no_zeroth_group(:,group_id_col);
nr_groups=max(group_ids);
nr_params=end_params_col-start_params_col+1;
group_stats=zeros(nr_groups,nr_params);
for i=1:nr_params
    group_stats(:,i)=accumarray(group_ids,tracks_no_zeroth_group(:,start_params_col+i-1),[],@mean);
end
output_args.MatchingGroupStats=group_stats;

%end getMatchingGroupMeans
end