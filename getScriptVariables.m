function script_variables=getScriptVariables(selected_assay)
%helper function for assayEditorGUI. read any script variables from the assay text

file_text=fileread(selected_assay);
%extract the script variables section
var_text=regexp(file_text,'%script variables(.*)%end script variables','tokens');
script_variables=regexp(var_text{1},'(?:\s*)([^=]*)=([^;]*);','tokens');
script_variables=script_variables{1};

%end getScriptVariables
end