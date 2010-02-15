function pair_scores=getPairScoresToSingle(pair_params,single_params,b_use_direction,unknown_param_weights,...
    param_weights,pair_ranking_order,pair_group_idx)
%see which one of two cells is a better match for a track or which of two tracks is a better match for a cell. this has to
%be done one cell pair at a time otherwise the best cell/track may not be picked
assert(size(pair_params,1)==2);
pair_ranks=rankParams(single_params,pair_params);
if (pair_group_idx==0)
    if (b_use_direction)
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,pair_ranking_order,unknown_param_weights);
    else
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,...
            pair_ranking_order(pair_ranking_order<max(pair_ranking_order)),unknown_param_weights(1:end-1));
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
