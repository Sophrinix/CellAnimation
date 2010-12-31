function [many_params_sorted sort_idx]=sortManyToOneUsingPairs(single_params, many_params,b_use_direction,unknown_param_weights,...
    param_weights,ranking_order,matching_group_idx,relevant_params_idx)
%helper function for CA tracking algorithm
%sort tracks by how well they match a particular cell or cells by how well
%they match a particular track. look at one pair at a time so each
%track/cell is pitted against another individually otherwise the best
%matching track/cell might not be picked. when ranking all the
%cells/tracks at once we have situations where the cell/tracks that has the
%most parameters matching is not the best match due to other poorly
%matching cells/tracks robbing parameter matches from the true best matching cell. by
%matching them head to head this situation is avoided.
many_nr=size(many_params,1);
many_params_sorted=many_params;
sort_idx=[1:many_nr]';
%can't do a straight insertion sort or any sorting algorithm that doesn't
%compare each element with every other element because for track rankings
%a<b and b<c does not imply a<c
for i=1:many_nr-1    
    for j=i:many_nr
        param1=many_params_sorted(j,:);
        sort1=sort_idx(j);
        b_smallest=true;
        for k=i:many_nr
            if (j==k)
                continue;
            end
            param2=many_params_sorted(k,:);            
            many_scores=getPairScoresToSingle([param1;param2],single_params,b_use_direction,unknown_param_weights,...
                param_weights,ranking_order,matching_group_idx,relevant_params_idx);
            if (many_scores(2)<many_scores(1))
                %this cannot be the smallest element
                b_smallest=false;
                break;
            end
        end
        if (b_smallest)
            if (i~=j)
                param2=many_params_sorted(i,:);
                sort2=sort_idx(i);
                many_params_sorted(i,:)=param1;
                sort_idx(i)=sort1;
                many_params_sorted(j,:)=param2;
                sort_idx(j)=sort2;
            end
            break;
        end
    end
end

%end sortManyToOneUsingPairs
end
