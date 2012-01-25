function importScriptVariables(handles)
%helper function for assayEditorGUI. import script variables from a text file

[file_name,path_name] = uigetfile('*.m','Select file containing script variables:');
if ~file_name
    return;
end
handles.ScriptVariables=getScriptVariables([path_name '/' file_name]);
guidata(handles.figure1,handles);

%end importScriptVariables
end