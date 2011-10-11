function new_list=expandText(listbox_list,selection_idx,modules_list,modules_map,sublevel_depth)
%get the name of the module which contains this chain
i=1;
while 1
    selection_text=listbox_list{selection_idx-i};
    if (strcmp(selection_text(1:9),'<html><b>')&&(getSelectionLevel(selection_text)==sublevel_depth))
        break;
    end
    i=i+1;
end
module_id=stripHTMLFromString(selection_text);
module_idx=modules_map.get(module_id);
module_struct=modules_list{module_idx};
selection_text=listbox_list{selection_idx};
chain_name=stripHTMLFromString(selection_text);
chain_idx=strcmp(chain_name,module_struct.ChainVars);
chain_name=module_struct.Chains(chain_idx);
%get the modules that are connected to this chain
submodules_idx=cellfun(@(x) strcmp(x.ChainName,chain_name),modules_list);
submodules_list=modules_list(submodules_idx);
modules_strings=formatModuleStrings(submodules_list);

if (selection_idx>1)
    new_list=[listbox_list(1:selection_idx); modules_strings];
else
    new_list=modules_strings;
end

if (selection_idx<length(listbox_list))
    new_list=[new_list; listbox_list((selection_idx+1):end)];
end

%end expandText
end