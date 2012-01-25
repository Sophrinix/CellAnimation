function [module_struct is_chain chain_name]=getModuleStruct(list_text,selection_idx,handles)
%helper function for assayEditorGUI. get the module struct corresponding to the current selection
selection_text=list_text{selection_idx};
sublevel_depth=getSelectionLevel(selection_text);
is_control=false;
if strcmp(selection_text(1:9),'<html><i>')
    %get the module text for the current chain
    chain_var=regexp(selection_text,'<html><i>(?:&nbsp;)*(\w*)<','tokens','once');
    is_chain=true;    
    i=1;
    while 1
        selection_text=list_text{selection_idx-i};
        if (strcmp(selection_text(1:9),'<html><b>')&&(getSelectionLevel(selection_text)==sublevel_depth))
            break;
        end
        i=i+1;
    end
elseif strcmp(selection_text(1:9),'<html><b>')
    is_chain=true;
    is_control=true;
else
    is_chain=false;    
end
module_id=stripHTMLFromString(selection_text);
modules_list=handles.ModulesList;
modules_map=handles.ModulesMap;
module_idx=modules_map.get(module_id);
module_struct=modules_list{module_idx};
if (~is_chain)
    chain_name=module_struct.ChainName;
else
    if (is_control)
        chain_name=module_struct.Chains{1};
    else        
        chain_idx=strcmp(chain_var,module_struct.ChainVars);
        chain_name=module_struct.Chains{chain_idx};
    end
end
%end getModuleStruct
end