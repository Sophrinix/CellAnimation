function checkBoxLabelsEvent()

global mtr_gui_struct;
mtr_gui_struct.ShowLabels=get(mtr_gui_struct.CheckBoxLabelsHandle,'Value');
updateTrackImage(mtr_gui_struct.CurFrame,mtr_gui_struct.ShowLabels);
if (mtr_gui_struct.SelectedCellID>0)
    selectCell(mtr_gui_struct.SelectedCellLabelID);    
end

end