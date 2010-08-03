function checkBoxOutlinesEvent()

global mtr_gui_struct;
mtr_gui_struct.ShowOutlines=get(mtr_gui_struct.CheckBoxOutlinesHandle,'Value');
updateTrackImage(mtr_gui_struct.CurFrame,mtr_gui_struct.ShowLabels,mtr_gui_struct.ShowOutlines);
addSelectionLayers();

end