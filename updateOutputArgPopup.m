function updateOutputArgPopup(handles)
%update the list of output args for the current module
%enable the popup boxes
%disable the manual edit box
set(handles.editManualValue,'Enable','on');
%enable the module output boxes
set(handles.popupOutputArgument,'Enable','on');
set(handles.popupModuleInstance,'Enable','on');
modules_list=get(handles.popupModuleInstance,'String');
selection_idx=get(handles.popupModuleInstance,'Value');
module_id=modules_list{selection_idx};
modules_map=handles.ModulesMap;
module_idx=modules_map.get(module_id);
modules_list=handles.ModulesList;
module_struct=modules_list{module_idx};
file_name=[module_struct.ModuleName '.m'];
output_args=getOutputArgs(file_name);
if ~isempty(output_args)
    set(handles.popupOutputArgument,'String',output_args);
    set(handles.popupOutputArgument,'Value',1);
end

%end updateOutputArgPopup
end

function output_args=getOutputArgs(module_path)
%read the output arguments from a module file
file_text=fileread(module_path);
%find the output args
search_pattern='output_args.(\w*)\s*=\s*';
output_tokens=regexp(file_text,search_pattern,'tokens');
%convert to cell array of strings
output_args=cellfun(@(x) x{1},output_tokens,'UniformOutput',false);
%remove duplicates
output_args=unique(output_args);

%end getOutputArgs
end