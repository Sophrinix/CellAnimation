function aeMenuNewAssay(hObject, eventdata, handles)

handles.CurrentAssay='';
handles.AssayDescription='';
handles.ScriptVariables={};
handles.ModulesList={};
handles.ModulesMap=java.util.HashMap;
set(handles.figure1,'Name','CellAnimation Assay Editor - Untitled');
set(handles.listboxCurrentAssay,'String','');
set(handles.listboxCurrentAssay,'Value',1);
guidata(handles.figure1,handles);

%end aeMenuNewAssay
end