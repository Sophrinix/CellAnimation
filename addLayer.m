function addLayer()
global sl_gui_struct;
global al_gui_struct;

gui_handle=addLayerGUI;
al_gui_struct.GUIHandle=gui_handle;
children_handles=get(gui_handle,'children');
al_gui_struct.EditSelectionLayerNameHandle=findobj(children_handles,'tag','editSelectionLayerName');
al_gui_struct.ComboColorHandle=findobj(children_handles,'tag','comboColor');
al_gui_struct.ComboLogicConnectorHandle=findobj(children_handles,'tag','comboLogicConnector');
al_gui_struct.ComboCellPropertyHandle=findobj(children_handles,'tag','comboCellProperty');
al_gui_struct.ComboOperatorHandle=findobj(children_handles,'tag','comboOperator');
al_gui_struct.EditValueHandle=findobj(children_handles,'tag','editValue');
al_gui_struct.TextConditionsHandle=findobj(children_handles,'tag','textConditions');
cell_properties=...
    {'Area';'Cell ID';'Generation';'Eccentricity';'End Frame';'Speed';'Start Frame';'Parent ID';'Perimeter';'RMS';'Solidity'};
set(al_gui_struct.ComboCellPropertyHandle,'String',cell_properties);
al_gui_struct.CellProperties=cell_properties;
logic_connectors={'AND';'OR'};
set(al_gui_struct.ComboLogicConnectorHandle,'String',logic_connectors);
al_gui_struct.LogicConnectors=logic_connectors;
operators={'=';'>';'<'};
set(al_gui_struct.ComboOperatorHandle,'String',operators);
al_gui_struct.Operators=operators;
layer_colors={'Aquamarine';'Black';'Blue';'Dark Brown';'Dark Green';'Lime Green';'Grey';'Orange';'Pink';'Purple';'Red';'Sienna';'Turqoise';'Violet';'Yellow'};
set(al_gui_struct.ComboColorHandle,'String',layer_colors);
al_gui_struct.LayerColors=layer_colors;
selection_names=sl_gui_struct.SelectionNames;
al_gui_struct.SelectionNames=selection_names;
waitfor(gui_handle);

new_selection_layer=al_gui_struct.NewSelectionLayer;
clear al_gui_struct;
selection_names=[selection_names {new_selection_layer.Name}];
sl_gui_struct.SelectionNames=selection_names;
sl_gui_struct.SelectionLayers=[sl_gui_struct.SelectionLayers; {new_selection_layer}];
set(sl_gui_struct.ListboxSelectionLayersHandle,'String',selection_names);


%end addLayer
end