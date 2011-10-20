function aeMenuNewAssay(hObject, eventdata, handles)
%helper function for assayEditorGUI. used to implement the "New Assay".
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