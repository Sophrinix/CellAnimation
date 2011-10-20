function module_text=formatModuleItem(module_struct)
%helper function for assayEditorGUI. format a module item for display in the assay list box

module_level=module_struct.Level;
if (module_struct.IsParent)
    %add the module but also display the chains structure
    ws=repmat('&nbsp;&nbsp;',1,module_level-1);
    module_text={['<html><b>' ws module_struct.InstanceName '</b></html>']};
    ws=repmat('&nbsp;&nbsp;',1,module_level);
    for j=1:length(module_struct.ChainVars)
        module_text=[module_text; {['<html><i>' ws module_struct.ChainVars{j} '</i></html>']}];
    end
else
    ws=repmat('&nbsp;&nbsp;',1,module_level-1);
    module_text={['<html>' ws module_struct.InstanceName '</html>']};
end

%end formatModuleItem
end