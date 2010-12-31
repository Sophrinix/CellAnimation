function checkBoxLabelsEvent()
%helper function for the manual tracking review module. used to turn the
%label display on and off

global mtr_gui_struct;
mtr_gui_struct.ShowLabels=get(mtr_gui_struct.CheckBoxLabelsHandle,'Value');
updateTrackImage(mtr_gui_struct.CurFrame,mtr_gui_struct.ShowLabels,mtr_gui_struct.ShowOutlines);
addSelectionLayers();

end