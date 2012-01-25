function addOutputArgument(handles)
%helper function for assayEditorGUI. add an output argument provider to the currently selected input argument
assay_list=get(handles.listboxInputArgumens,'String');
selection_idx=get(handles.listboxInputArgumens,'Value');
selection_text=assay_list{selection_idx};
if (length(selection_text)>9)&&strcmp(selection_text(1:9),'<html><i>')
    warndlg('You need to select an argument name (not in italics)');
    return;
end
if strcmp(selection_text(1:6),'<html>')
    %remove the html formatting
    selection_text=selection_text(25:(end-14));
    %display the selection text without the red warning format
    assay_list{selection_idx}=selection_text;
end
output_arg(1)={selection_text};
module_struct=handles.ModuleStruct;
module_idx=get(handles.popupModuleInstance,'Value');
popup_list=get(handles.popupModuleInstance,'String');
module_instance=popup_list{module_idx};
output_arg(2)={module_instance};
module_idx=get(handles.popupOutputArgument,'Value');
popup_list=get(handles.popupOutputArgument,'String');
module_output=popup_list{module_idx};
output_arg(3)={['''' module_output '''']};
i=selection_idx+1;
list_len=length(assay_list);
while 1
    if (i>list_len)
        break;
    end
    selection_text=assay_list{i};
    if (length(selection_text)<21)
        break;
    end
    if ~strcmp(selection_text(1:21),'<html><i>&nbsp;Output')
        break;
    end
    i=i+1;
end
module_struct.OutputArgs=[module_struct.OutputArgs {output_arg}];
%get the number of output arguments that belong to this input arg
cur_arg_idx=cellfun(@(x) strcmp(x{1},output_arg(1)), module_struct.OutputArgs);
output_arg_string=['<html><i>&nbsp;Output' num2str(sum(cur_arg_idx)) '</i></html>'];
assay_list=[assay_list(1:i-1);output_arg_string;assay_list(i:end)];
set(handles.listboxInputArgumens,'String',assay_list);
handles.ModuleStruct=module_struct;
guidata(handles.figure1,handles);

%end addOutputArgument
end