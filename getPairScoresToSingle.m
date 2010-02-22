function pair_scores=getPairScoresToSingle(pair_params,single_params,b_use_direction,unknown_param_weights,...
    param_weights,pair_ranking_order,pair_group_idx,relevant_params_idx)
%see which one of two cells is a better match for a track or which of two tracks is a better match for a cell. this has to
%be done one cell pair at a time otherwise the best cell/track may not be picked
assert(size(pair_params,1)==2);
%keep only the relevant parameters
irrelevant_cols=find(relevant_params_idx==0);
irrelevant_cols_idx=ismember(pair_ranking_order,irrelevant_cols);
pair_ranking_order(irrelevant_cols_idx)=[];
for i=1:length(pair_ranking_order)
    %need to adjust the index of the columns that were above
    %columns that were removed
    pair_ranking_order(i)=pair_ranking_order(i)-sum(irrelevant_cols<pair_ranking_order(i));
end
if(~b_use_direction)
    relevant_params_idx(2)=[];
    if (pair_group_idx==0)
        unknown_param_weights=unknown_param_weights(1:end-1);
    else
       param_weights=param_weights(1:end-1);
    end
end
pair_params=pair_params(:,relevant_params_idx);
single_params=single_params(:,relevant_params_idx);
if (pair_group_idx==0)
        unknown_param_weights=unknown_param_weights(relevant_params_idx);
    else
       param_weights=param_weights(relevant_params_idx);
end
pair_ranks=rankParams(single_params,pair_params);
if (pair_group_idx==0)
    if (b_use_direction)
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,pair_ranking_order,unknown_param_weights);
    else        
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,...
            pair_ranking_order(pair_ranking_order<max(pair_ranking_order)),unknown_param_weights);
    end
else
    if (b_use_direction)
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,pair_ranking_order,param_weights);
    else
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,...
            pair_ranking_order(pair_ranking_order<max(pair_ranking_order)),param_weights(1:end-1));
    end
end

%end getPairScoresToSingle
end
