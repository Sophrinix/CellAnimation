function saveChanges(hObject, eventdata, handles)
%helper function for manual segmentation review. save changes made to the
%label matrix and close the GUI
global msr_gui_struct;

gui_handle=msr_gui_struct.GuiHandle;
msr_gui_struct.FigurePosition=get(gui_handle,'Position');
msr_gui_struct.ObjectsLabel=makeContinuousLabelMatrix(msr_gui_struct.ObjectsLabel);
close(gui_handle);

%end saveChanges
end