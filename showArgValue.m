function arg_type=showArgValue(arg_text,provider_text,module_struct,handles)
%update the inputArgumentsGUI with the current value of the argument
%determine if selected value it's manual or output
%extract the argument name and provider
search_pattern='>*(\w*)<*';
arg_name=regexp(arg_text,search_pattern,'once','tokens');
search_pattern='>&nbsp;([a-zA-Z]*)\d*<';
provider_type=regexp(provider_text,search_pattern,'once','tokens');
j=1;
if strcmp(provider_type,'Value')
    %display a manually set value
    %disable the module output boxes
    arg_type='Manual';
    arg_idx=regexp(provider_text,'Value([0-9]*)','once','tokens');
    arg_idx=str2double(arg_idx{1});
    set(handles.popupOutputArgument,'Enable','off');
    set(handles.popupModuleInstance,'Enable','off');
    %enable the manual edit box
    set(handles.editManualValue,'Enable','on');
    static_params=module_struct.StaticParameters;
    for i=1:length(static_params)
        cur_val=static_params{i};
        if strcmp(arg_name,cur_val{1})
            if (arg_idx~=j)
                j=j+1;
            else
                %found the argument show the value
                set(handles.editManualValue,'String',cur_val{2});
                break;
            end
        end
    end    
else
    %display a value obtained as an output arg from a module
    %disable the manual edit box
    arg_type='Output';
    arg_idx=regexp(provider_text,'Output([0-9]*)','once','tokens');
    arg_idx=str2double(arg_idx{1});    
    %enable the module output boxes
    set(handles.popupOutputArgument,'Enable','on');
    set(handles.popupModuleInstance,'Enable','on');    
    output_params=module_struct.OutputArgs;    
    for i=1:length(output_params)
        cur_val=output_params{i};
        if strcmp(arg_name,cur_val{1})
            if (arg_idx~=j)
                j=j+1;
            else
                %found the argument update the popup lists
                module_id=cur_val{2};
                modules_list=get(handles.popupModuleInstance,'String');
                module_idx=find(strcmp(module_id,modules_list));
                %update the popup selection
                set(handles.popupModuleInstance,'Value',module_idx);
                %update the args popup
                updateOutputArgPopup(handles);
                args_list=get(handles.popupOutputArgument,'String');
                arg_name=cur_val{3};
                arg_name=arg_name(2:(end-1));
                arg_idx=find(strcmp(arg_name,args_list));
                %update args popup selection
                set(handles.popupOutputArgument,'Value',arg_idx);
                break;
            end
        end        
    end
    set(handles.editManualValue,'Enable','off');
end

guidata(handles.figure1,handles);
%end showArgValue
end