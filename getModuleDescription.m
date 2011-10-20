function module_description=getModuleDescription(module_path)
%helper function for assayEditorGUI. get the description of a module from the module file
module_description='';
fi=fopen(module_path);
module_name=module_path(1:(end-2));
tl=fgetl(fi);
while isempty(strfind(tl,module_name))
    tl=fgetl(fi);
end
tl=fgetl(fi);
while (length(tl)>0)&&(tl(1)=='%')
    module_description=[module_description ' ' tl(2:end)];
    tl=fgetl(fi);
end
fclose(fi);

%end getModuleDescription
end