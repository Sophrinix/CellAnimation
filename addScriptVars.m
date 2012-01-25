function vars_text=addScriptVars(handles)
%helper function for assayEditorGUI. create a text file defining the script variables

vars_text=['%script variables' 10];
script_vars=handles.ScriptVariables;
vars_def=[];
for i=1:length(script_vars)
    cur_var=script_vars{i};
    vars_def=[vars_def cur_var{1} '=' cur_var{2} ';' 10];
end
vars_text=[vars_text vars_def '%end script variables' 10];

%end addScriptVars
end
