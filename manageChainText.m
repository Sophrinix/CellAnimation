function new_list=manageChainText(listbox_list,selection_idx,modules_list,modules_map)
%collapse/expand the submodule list for the current module
[is_expanded selection_level]=isChainExpanded(listbox_list,selection_idx);
if (is_expanded)
    new_list=collapseText(listbox_list,selection_idx,selection_level);    
else
    new_list=expandText(listbox_list,selection_idx,modules_list,modules_map,selection_level);
end

%end manageChainText
end