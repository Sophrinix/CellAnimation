function moveModule(handles,move_dir)
%helper function for assayEditorGUI. move a module up or down in the assay list
assay_list=get(handles.listboxCurrentAssay,'String');
selection_idx=get(handles.listboxCurrentAssay,'Value');
if (selection_idx==1)&&(move_dir==-1)
    return;
end
list_len=length(assay_list);
if (selection_idx==list_len)&&(move_dir==1)
    return;
end
if (selection_idx==(list_len-1))&&(move_dir==1)
    at_end=true;
else
    at_end=false;
end
    
selection_text=assay_list{selection_idx};
if strcmp(selection_text(1:9),'<html><i>')
    warndlg('This is not a module. You cannot move parts of a module!');
    return;
end
%get the module struct
module_instance=stripHTMLFromString(selection_text);
modules_list=handles.ModulesList;
modules_map=handles.ModulesMap;
module_idx=modules_map.get(module_instance);
module_struct=modules_list{module_idx};
new_idx=selection_idx+move_dir;
%this is the module above/below which the current module is being moved
selection_text=assay_list{new_idx};
module_found=false;
chain_vars=false;
while strcmp(selection_text(1:9),'<html><i>')
    new_idx=new_idx+move_dir;
    if (new_idx==list_len)
        fixed_struct=getModuleStruct(assay_list,selection_idx,handles);
        fixed_idx=module_map.get(fixed_struct.ModuleInstance);
        module_found=true;
        break;
    end
    selection_text=assay_list{new_idx};
    chain_vars=true;
end
if (~module_found)
    fixed_instance=stripHTMLFromString(selection_text);
    fixed_idx=modules_map.get(fixed_instance);
    fixed_struct=modules_list{fixed_idx};    
end
modules_list(module_idx)=[];
if (module_idx<fixed_idx)
    fixed_idx=fixed_idx-1;
end
assay_list(selection_idx)=[];
if (chain_vars&&fixed_struct.IsParent)
    selection_idx=new_idx;    
else
    selection_idx=selection_idx-1;
end

module_struct.Parent=fixed_struct.Parent;
module_struct.Level=fixed_struct.Level;
module_struct.ChainName=fixed_struct.ChainName;

if (move_dir==1)
    if chain_vars
        %skipped chains so insert before rather than after
        %fixed_struct;
        fixed_idx=fixed_idx-1;
    end
    %moving down
    if (at_end)
        %at the end of list
        modules_list=[modules_list; {module_struct}];
        assay_list=[assay_list; formatModuleItem(module_struct)];        
    else
        if (fixed_struct.IsParent)
            selection_idx=selection_idx+2;
            list_len=length(assay_list);
            while 1
                if ((selection_idx+1)>list_len)
                    break;
                end
                selection_text=assay_list{selection_idx+1};
                if ~strcmp(selection_text(1:9),'<html><i>')
                    break;
                end
                selection_idx=selection_idx+1;
            end
            %figure out if the insertion point is inside one of the fixed
            %module's chains
            if isChainExpanded(assay_list,selection_idx)
                module_struct.Parent=fixed_struct.InstanceName;
                module_struct.Level=fixed_struct.Level+1;
                %get the chain name
                chain_var=stripHTMLFromString(assay_list{selection_idx});
                chain_idx=strcmp(fixed_struct.ChainVars,chain_var);
                chain_name=fixed_struct.Chains(chain_idx);               
                module_struct.ChainName=chain_name{1};
                submodule_instance=stripHTMLFromString(assay_list{selection_idx+1});
                %adjust the fixed_idx so this is the first submodule
                fixed_idx=modules_map.get(submodule_instance)-2;
            end
            selection_idx=selection_idx-1;
        end
        modules_list=[modules_list(1:fixed_idx); module_struct; modules_list((fixed_idx+1):end)];
        assay_list=[assay_list(1:(selection_idx+1)); formatModuleItem(module_struct); assay_list((selection_idx+2):end)];        
    end
    set(handles.listboxCurrentAssay,'Value',selection_idx+2);
else
    %moving up
    if chain_vars&&(~fixed_struct.IsParent)
        %skipped chains so insert after rather than before
        %fixed_struct;
        fixed_idx=fixed_idx+1;
    end    
    if (selection_idx==1)
        %at the beginning of the list
        modules_list=[{module_struct}; modules_list];
        assay_list=[formatModuleItem(module_struct); assay_list];
    else
        modules_list=[modules_list(1:fixed_idx-1); module_struct; modules_list(fixed_idx:end)];
        assay_list=[assay_list(1:selection_idx-1); formatModuleItem(module_struct); assay_list(selection_idx:end)];
    end
    set(handles.listboxCurrentAssay,'Value',selection_idx);
end

modules_map=java.util.HashMap;
%rebuild the hashmap
for i=1:length(modules_list)
    modules_map.put(modules_list{i}.InstanceName,i);
end
handles.ModulesList=modules_list;
handles.ModulesMap=modules_map;
guidata(handles.figure1,handles);
%update the listbox
set(handles.listboxCurrentAssay,'String',assay_list);

%end moveModule
end