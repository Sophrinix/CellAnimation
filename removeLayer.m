function removeLayer()
global sl_gui_struct;

layers_txt=get(sl_gui_struct.ListboxSelectionLayersHandle,'String');
if isempty(layers_txt)
    return;
end
layer_idx=get(sl_gui_struct.ListboxSelectionLayersHandle,'Value');
if isempty(layer_idx)
    return;
end
selection_layers=sl_gui_struct.SelectionLayers;
selection_layers(layer_idx)=[];
sl_gui_struct.SelectionLayers=selection_layers;
selection_names=sl_gui_struct.SelectionNames;
selection_names(layer_idx)=[];
set(sl_gui_struct.ListboxSelectionLayersHandle,'String',selection_names);

%end removeLayer
end