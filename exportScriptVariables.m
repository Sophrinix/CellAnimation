function exportScriptVariables(handles)
%export the current set of script variables to a file

[file_name path_name]=uiputfile('*.m','Export Script Variables to:');
if (file_name==0)
    return;
end
file_text=addScriptVars(handles);
fid=fopen([path_name '/' file_name],'wt');
fwrite(fid,file_text);
fclose(fid);

%end exportScriptVariables
end