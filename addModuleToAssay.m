function addModuleToAssay(handles)
%helper function for assayEditorGUI. add a module to the current assay
assay_list=get(handles.listboxCurrentAssay,'String');
selection_idx=get(handles.listboxCurrentAssay,'Value');

available_modules=get(handles.listboxAvailableModules,'String');
cur_idx=get(handles.listboxAvailableModules,'Value');
module_name=available_modules{cur_idx};
module_name=module_name(1:end-2);
insertModule(module_name,assay_list,selection_idx,handles);

%end addModuleToAssay
end

function insertModule(module_name,assay_list,selection_idx,handles)
%insert the new module in the modules list
module_struct.ModuleName=module_name;
if isempty(assay_list)
    parents_list={''};
    chains_list={'functions_list'};
    cur_module=[];
else
    [parents_list chains_list cur_module]=getPossibleParentModules(assay_list,selection_idx,handles);
end
[is_ok parent_idx module_instance]=moduleParentGUI('ParentsList',parents_list);
if (~is_ok)
    return;
end
modules_list=handles.ModulesList;
existing_instances=cellfun(@(x) x.InstanceName,modules_list,'UniformOutput',false);
if max(strcmp(module_instance,existing_instances))
    %this instance name is taken
    warndlg('This instance name is already taken! Please use another name.');
    return;
end
module_struct.InstanceName=module_instance;
switch module_name
    case {'forLoop','whileLoop'}
        module_struct.IsParent=true;
        module_struct.ChainVars={'LoopFunctions'};
        module_struct.Chains{1}=[module_instance module_struct.ChainVars{1}];
    case 'if_statement'
        module_struct.IsParent=true;
        module_struct.ChainVars={'ElseFunctions','IfFunctions'};
        module_struct.Chains{1}=lower([module_instance module_struct.ChainVars{1}]);
        module_struct.Chains{2}=lower([module_instance module_struct.ChainVars{2}]);        
    otherwise
        module_struct.IsParent=false;
        module_struct.ChainVars={};
        module_struct.Chains={};
end
module_struct.Parent=parents_list{parent_idx};
module_struct.ChainName=chains_list{parent_idx};
%get the static args
module_struct.StaticParameters={};
module_struct.OutputArgs={};
module_struct.InputArgs={};
module_struct.KeepOutputArgs={};
modules_map=handles.ModulesMap;
%figure out the level of the new module
if isempty(module_struct.Parent)
    module_struct.Level=1;
else
    parent_idx=modules_map.get(module_struct.Parent);
    parent_struct=modules_list{parent_idx};
    module_struct.Level=parent_struct.Level+1;
end
%add the new module to the modules list
if isempty(cur_module)
    %special case - empty list
    insert_idx=1;
    modules_list={module_struct};
elseif (selection_idx==length(assay_list))
    %special case - at the end of the list
    if (module_struct.Level==1)
        %add the module at the end of the modules list
        modules_list=[modules_list; module_struct];
        insert_idx=length(modules_list);
    else
        %add the module right before its parent
        insert_idx=modules_map.get(module_struct.Parent);  
        modules_list=[modules_list(1:(insert_idx-1)); module_struct; modules_list(insert_idx:end)];
    end
elseif isempty(cur_module.Chains)||(module_struct.Level==cur_module.Level)
    %regular module or adding at same level as control module - add the new
    %module right after    
    cur_module_idx=modules_map.get(cur_module.InstanceName);
    modules_list=[modules_list(1:cur_module_idx); module_struct; modules_list((cur_module_idx+1):end)];
    insert_idx=cur_module_idx+1;
else
    %control module - add the new module before the first sub-module
    submodules_idx=find(cellfun(@(x) strcmp(x.ChainName,module_struct.ChainName),modules_list));
    min_idx=min(submodules_idx);
    if isempty(min_idx)
        %no submodule-add before parent
        modules_list=[modules_list; module_struct];
        insert_idx=length(modules_list);
    else
        insert_idx=modules_map.get(module_struct.Parent);  
        modules_list=[modules_list(1:(insert_idx-1)); module_struct; modules_list(insert_idx:end)];
    end    
end

modules_set=modules_map.entrySet;
set_iter=modules_set.iterator;
while (set_iter.hasNext())
    map_entry=set_iter.next();
    cur_val=double(map_entry.getValue());
    if (cur_val>=insert_idx)
        map_entry.setValue(cur_val+1);
    end
end
%update the module map
modules_map.put(module_struct.InstanceName,insert_idx);

%update the handles struct
handles.ModulesList=modules_list;
handles.ModulesMap=modules_map;
guidata(handles.figure1, handles);
module_text=formatModuleItem(module_struct);
%add the new module instance to the dialog
if isempty(cur_module)
    %special case - empty list
    assay_list=module_text;
    insert_idx=0;
elseif (selection_idx==length(assay_list))
    %special case - at the end of the list
    assay_list=[assay_list; module_text];
    insert_idx=selection_idx;
elseif isempty(cur_module.Chains)||(module_struct.Level==cur_module.Level)
    %regular module or adding at same level as control module - add the new module right after
    if (cur_module.IsParent)&&(selection_idx~=length(assay_list))
        %add the new module past the chains
        selection_text=assay_list{selection_idx+1};
        while(strcmp(selection_text(1:9),'<html><i>'))
            selection_idx=selection_idx+1;
            if selection_idx>=length(assay_list)
                break;
            end
            selection_text=assay_list{selection_idx+1};
        end
    end
    assay_list=[assay_list(1:selection_idx); module_text; assay_list((selection_idx+1):end)];
    insert_idx=selection_idx;
else
    %control module - add the new module below the appropriate chain
    chain_name=module_struct.ChainName;
    %find the chain var    
    chain_idx=strcmp(chain_name,parent_struct.Chains);
    chain_var=parent_struct.ChainVars(chain_idx);
    selection_text=assay_list{selection_idx};
    module_level=module_struct.Level;
    if strcmp(selection_text(1:9),'<html><i>')
        insert_idx=selection_idx;
    else
        %find the insert index
        i=selection_idx+1;        
        while 1
            selection_text=assay_list{i};
            if (strcmp(selection_text(1:9),'<html><i>')&&((getSelectionLevel(selection_text)+1)==module_level))
                chain_name=regexp(selection_text,'<html><i>(?:&nbsp;)*(\w*)<','tokens','once');
                if strfind(chain_var{1},chain_name{1})
                    insert_idx=i;
                    break;
                end
            end
            i=i+1;
        end        
    end
    [is_expanded selection_level]=isChainExpanded(assay_list,insert_idx);
    if (~is_expanded)&&(selection_level==(module_level-1))
        assay_list=expandText(assay_list,insert_idx,modules_list,modules_map,parent_struct.Level);        
    else
        assay_list=[assay_list(1:insert_idx); module_text; assay_list((insert_idx+1):end)];
    end
end

set(handles.listboxCurrentAssay,'String',assay_list);
set(handles.listboxCurrentAssay,'Value',insert_idx+1);

%end insertModule
end

function [parents_list chains_list cur_module]=getPossibleParentModules(assay_list,selection_idx,handles)
%get a list of possible parent modules for the module about to be inserted
%along with the corresponding chain variable name - if a chain variable is selected return that, for control modules return the first chain var
%,for everything else return the chain they're attached to. also return the
%module structure for the current module
list_len=length(assay_list);
level_1=getSelectionLevel(assay_list{selection_idx});
[cur_module is_chain chain_name]=getModuleStruct(assay_list,selection_idx,handles);
if (is_chain)
    if(selection_idx==list_len)
        parents_list{1}=cur_module.InstanceName;
        chains_list{1}=chain_name;
    else
        parents_list{1}=cur_module.InstanceName;        
        chains_list{1}=chain_name;
    end
else
    parents_list{1}=cur_module.Parent;
    chains_list{1}=chain_name;
end
if (selection_idx==list_len)
    if ~isempty(parents_list{1})
        %if the selection is at the end of the list we may wish to add the
        %module to one of several levels. get the parents for all the levels
        min_level=1;
        max_level=level_1;
        modules_list=handles.ModulesList;
        modules_map=handles.ModulesMap;
        parent_module=cur_module;
        for i=2:(max_level-min_level+1)
            if ((i==2)&&(~is_chain))
                %parent for current module has been added already
                continue;
            end
            parent_id=parent_module.Parent;
            parents_list{i-min_level+1}=parent_id;
            chains_list{i-min_level+1}=parent_module.ChainName;
            parent_idx=modules_map.get(parent_id);
            parent_module=modules_list{parent_idx};
        end
        %add the main function chain
        parents_list=[parents_list {''}];
        chains_list=[chains_list 'functions_list'];
    end
else
    level_2=getSelectionLevel(assay_list{selection_idx+1});
    if (level_1>level_2)
        [module_struct is_chain]=getModuleStruct(assay_list,selection_idx+1,handles);
        chains_list{2}=chain_name;
        if is_chain
            parents_list=[parents_list {module_struct.InstanceName}];            
        else
            parents_list=[parents_list {module_struct.Parent}];
        end
    end
end



%end getPossibleParentModules
end