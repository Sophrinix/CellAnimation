function current_selection=populateModuleInstancesPopup(handles)
%populate the module instance popup

modules_list=handles.ModulesList;
module_instances=cellfun(@(x) x.InstanceName, modules_list,'UniformOutput',false);
module_instances=sort(module_instances);
set(handles.popupModuleInstance,'String',module_instances);
current_selection=module_instances{1};

%end populateModuleInstancesPopup
end