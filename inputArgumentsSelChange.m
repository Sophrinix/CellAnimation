function inputArgumentsSelChange(handles)
%callback for inputArgumentsGUI

if strcmp(handles.SelectionType,'ArgValue')&&~(handles.Erased)
    handles.ModuleStruct=updateArgValue(handles);
end
handles.Erased=false;
guidata(handles.figure1,handles);
input_strings=get(handles.listboxInputArgumens,'String');
selection_idx=get(handles.listboxInputArgumens,'Value');
selection_text=input_strings{selection_idx};
handles.SelectionIndex=selection_idx;
arg_text=selection_text;
i=0;
%find the current module instance
while(1)
    if (isempty(strfind(arg_text,'&nbsp')))
        break;
    else
        i=i+1;
    end
    arg_text=input_strings{selection_idx-i};
end

module_struct=handles.ModuleStruct;
if (i==0)
    %argument is selected show description
    %getArgumentDescription
    selection_type='ArgName';
    updateOutputArgPopup(handles);
else
    selection_type='ArgValue';
    if strcmp(selection_text(1:20),'<html><i>&nbsp;Value')
        handles.SelectionValue=get(handles.editManualValue,'String');
    end    
    handles.ArgType=showArgValue(arg_text,selection_text,module_struct,handles);
end
handles.SelectionType=selection_type;
guidata(handles.figure1,handles);


%end inputArgumentsSelChange
end