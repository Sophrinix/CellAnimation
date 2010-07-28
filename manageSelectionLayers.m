function manageSelectionLayers()
global sl_gui_struct;
global mtr_gui_struct;

selection_names=getSelectionNames();
sl_gui_struct.SelectionNames=selection_names;
gui_handle=selectionLayersGUI();
children_handles=get(gui_handle,'children');
sl_gui_struct.SelectionLayers=mtr_gui_struct.SelectionLayers;
sl_gui_struct.ListboxSelectionLayersHandle=findobj(children_handles,'tag','listboxSelectionLayers');
set(sl_gui_struct.ListboxSelectionLayersHandle,'String',selection_names);
waitfor(gui_handle);

mtr_gui_struct.SelectionLayers=sl_gui_struct.SelectionLayers;
clear sl_gui_struct;
updateTrackImage(mtr_gui_struct.CurFrame,mtr_gui_struct.ShowLabels);
addSelectionLayers();

%end manageSelectionLayers
end