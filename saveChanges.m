function saveChanges(hObject, eventdata, handles)
global msr_gui_struct;

gui_handle=msr_gui_struct.GuiHandle;
msr_gui_struct.FigurePosition=get(gui_handle,'Position');
close(gui_handle);

%end saveChanges
end