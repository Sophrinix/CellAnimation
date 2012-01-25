function module_struct=validateModuleArgs(handles)
%helper function for assayEditorGUI. remove any parameters that refer to modules which are no longer part of
%the assay
module_struct=handles.ModuleStruct;
output_modules=cellfun(@(x) x{2},module_struct.OutputArgs,'UniformOutput',false);
modules_names=cellfun(@(x) x.InstanceName,handles.ModulesList,'UniformOutput',false);
params_idx=ismember(output_modules,modules_names);
module_struct.OutputArgs(~params_idx)=[];

end