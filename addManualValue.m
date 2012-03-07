function addManualValue(handles)
%helper function for assayEditorGUI. add a manual value to the currently selected input argument
assay_list=get(handles.listboxInputArgumens,'String');
selection_idx=get(handles.listboxInputArgumens,'Value');
selection_text=assay_list{selection_idx};
if (length(selection_text)>9)&&strcmp(selection_text(1:9),'<html><i>')
    warndlg('You need to select an argument name (not in italics)');
    return;
end
if (length(selection_text)>6&&strcmp(selection_text(1:6),'<html>'))
    %remove the html formatting
    selection_text=selection_text(25:(end-14));
    %display the selection text without the red warning format
    assay_list{selection_idx}=selection_text;
end
output_arg(1)={selection_text};
module_struct=handles.ModuleStruct;
manual_value=get(handles.editManualValue,'String');
output_arg(2)={manual_value};
i=selection_idx+1;
j=i;
list_len=length(assay_list);
while 1
    if (j>list_len)
        break;
    end
    selection_text=assay_list{j};
    if (length(selection_text)<21)
        break;
    end
    if strcmp(selection_text(1:21),'<html><i>&nbsp;Output')
        j=j+1;
        continue;
    end
    if ~strcmp(selection_text(1:20),'<html><i>&nbsp;Value')
        break;
    end
    j=j+1;
    i=i+1;
end
module_struct.StaticParameters=[module_struct.StaticParameters {output_arg}];
value_arg_string=['<html><i>&nbsp;Value' num2str(i-selection_idx) '</i></html>'];
assay_list=[assay_list(1:(j-1));value_arg_string;assay_list(j:end)];
set(handles.listboxInputArgumens,'String',assay_list);
handles.ModuleStruct=module_struct;
guidata(handles.figure1,handles);

%end addManualValue
end