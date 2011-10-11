function module_struct=updateArgValue(handles)
%update manual argument value
% if isempty(handles.SelectionValue)
%     return;
% end
if strcmp(handles.ArgType,'Output')
    module_struct=handles.ModuleStruct;
    return;
end
man_value=get(handles.editManualValue,'String');
assay_list=get(handles.listboxInputArgumens,'String');
selection_idx=handles.SelectionIndex;
selection_text=assay_list{selection_idx};
arg_name=selection_text;
%get the argument name
while strcmp(arg_name(1:9),'<html><i>')
    selection_idx=selection_idx-1;
    arg_name=assay_list{selection_idx};
    if length(arg_name)<9
        break;
    end    
end
module_struct=handles.ModuleStruct;
arg_nr=regexp(selection_text,'([0-9])','tokens','once');
arg_nr=str2double(arg_nr{1});
%get the argument indices
static_idx=find(cellfun(@(x) strcmp(x{1},arg_name), module_struct.StaticParameters));
static_idx=static_idx(arg_nr);
%update the value
module_struct.StaticParameters{static_idx}{2}=man_value;

%end updateArgValue
end