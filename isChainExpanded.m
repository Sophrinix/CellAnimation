function [is_expanded selection_level]=isChainExpanded(listbox_list,selection_idx)
%determine the state of the current chain: expanded or collapsed
selection_text=listbox_list{selection_idx};
selection_level=getSelectionLevel(selection_text);
if (selection_idx==length(listbox_list))
    %selection is at bottom of the list so expand
    is_expanded=false;    
    return;
end

%get the level of the instance below to determine the current state
prev_level=getSelectionLevel(listbox_list{selection_idx+1});

if (selection_level>=prev_level)
    is_expanded=false;
else
    is_expanded=true;
end

%end isChainExpanded
end