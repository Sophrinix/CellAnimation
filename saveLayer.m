function saveLayer()
global al_gui_struct;

selection_name=get(al_gui_struct.EditSelectionLayerNameHandle,'String');
if (isempty(selection_name))
    warndlg('No selection name has been entered!');
    return;
end
if (max(strcmp(selection_name,al_gui_struct.SelectionNames)))
    warndlg('This selection name is already in use!');
    return;
end
if (isempty(al_gui_struct.Conditions))
    warndlg('There are no conditions!');
    return;
end
layer_colors=al_gui_struct.LayerColors;
selection_color=layer_colors{get(al_gui_struct.ComboColorHandle,'value')};
selection_layer.Name=selection_name;
selection_layer.Color=selection_color;
selection_layer.Conditions=al_gui_struct.Conditions;
al_gui_struct.NewSelectionLayer=selection_layer;
close(al_gui_struct.GUIHandle);

%end saveLayer
end