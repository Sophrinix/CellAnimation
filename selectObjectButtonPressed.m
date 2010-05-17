function selectObjectButtonPressed(hObject,eventdata,handles)
global msr_gui_struct;
button_value=get(hObject,'Value');
cells_lbl=msr_gui_struct.ObjectsLabel;
image_data=label2rgb(cells_lbl);
set(msr_gui_struct.ImageHandle,'CData',image_data);
if (button_value==1)
    %toggle select blob button off
    set(msr_gui_struct.SelectBlobButtonHandle,'Value',0);    
    %disable blob action buttons
    set(msr_gui_struct.ResegmentBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RestoreBlobButtonHandle,'Enable','off');
    %enable object action buttons
    set(msr_gui_struct.JoinObjectsButtonHandle,'Enable','on');
    set(msr_gui_struct.RemoveObjectButtonHandle,'Enable','on');
    msr_gui_struct.CurrentAction='SelectObject';
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.SelectedObjectID=[];
else
    %disable object action buttons
    set(msr_gui_struct.JoinObjectsButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveObjectButtonHandle,'Enable','off');
    msr_gui_struct.CurrentAction='';
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.SelectedObjectID=[];
end

%end selectBlobButtonPressed
end