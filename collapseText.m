function new_list=collapseText(listbox_list,selection_idx,sublevel_depth)
%helper function for assayEditorGUI. collapse the submodules belonging to the current module
list_head=listbox_list(1:selection_idx);
list_tail=listbox_list((selection_idx+1):end);
items_level=cellfun(@getSelectionLevel,list_tail);
%find any items at this level that are chains
i=1;
tail_len=length(list_tail);
while((i<=tail_len)&&(items_level(i)>sublevel_depth))
    selection_text=list_tail{i};
    if ((items_level(i)==sublevel_depth)&&strcmp(selection_text(1:9),'<html><i>'))
        %prevent the chain from being collapsed
        items_level(i:end)=0;
        break;
    end
    i=i+1;
end
keep_idx=find(items_level<=sublevel_depth);
if ~isempty(keep_idx)
    items_level(keep_idx(1):end)=0;
end
new_list=[list_head; list_tail(items_level<=sublevel_depth)];

%end collapseText
end