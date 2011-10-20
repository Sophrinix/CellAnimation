function removeModuleFromAssay(handles)
%helper function for assayEditorGUI. remove the selected module from the assay

%get the selected module struct
assay_list=get(handles.listboxCurrentAssay,'String');
selection_idx=get(handles.listboxCurrentAssay,'Value');
selection_text=assay_list{selection_idx};
if strcmp(selection_text(1:9),'<html><i>')
    warndlg('This is not a module. You cannot delete parts of a module!');
    return;
end
module_instance=stripHTMLFromString(selection_text);
modules_list=handles.ModulesList;
modules_map=handles.ModulesMap;
module_idx=modules_map.get(module_instance);
module_struct=modules_list{module_idx};
if (module_struct.IsParent)
    %this is a control module
    %remove the chain vars from the assay list
    chain_idx=selection_idx+1;
    selection_text=assay_list{chain_idx};
    list_len=length(assay_list);
    while strcmp(selection_text(1:9),'<html><i>')
        %collapse chain before deleting it
        assay_list=collapseText(assay_list,chain_idx,module_struct.Level);
        assay_list(chain_idx)=[];
        list_len=list_len-1;
        if (chain_idx>list_len)
            break;
        end
        selection_text=assay_list{chain_idx};        
    end    
end

[modules_list modules_map]=deleteModule(module_struct,modules_list,modules_map);
handles.ModulesList=modules_list;
handles.ModulesMap=modules_map;
%save the new handles struct
guidata(handles.figure1,handles);

assay_list(selection_idx)=[];
list_len=length(assay_list);
if (selection_idx>list_len)
    selection_idx=list_len;
end
set(handles.listboxCurrentAssay,'Value',selection_idx);
set(handles.listboxCurrentAssay,'String',assay_list);

%end removeModuleFromAssay
end

function [modules_list modules_map]=deleteModule(module_struct,modules_list,modules_map)
%remove the module from the modules_list and its index from the module_map

if module_struct.IsParent
    %remove the module's children
    children_idx=cellfun(@(x) strcmp(x.Parent,module_struct.InstanceName),modules_list);
    children_list=modules_list(children_idx);
    for i=1:length(children_list)
        [modules_list modules_map]=deleteModule(children_list{i},modules_list,modules_map);
    end
end

module_idx=modules_map.get(module_struct.InstanceName);
modules_list(module_idx)=[];
modules_map.remove(module_struct.InstanceName);
modules_set=modules_map.entrySet;
set_iter=modules_set.iterator;
%update the indexes above the removal point
while (set_iter.hasNext())
    map_entry=set_iter.next();
    cur_val=double(map_entry.getValue());
    if (cur_val>module_idx)
        map_entry.setValue(cur_val-1);
    end
end

%end deleteModule
end