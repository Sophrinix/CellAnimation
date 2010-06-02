function selectBlobButtonPressed(hObject,eventdata,handles)
global msr_gui_struct;
button_value=get(hObject,'Value');
objects_lbl=msr_gui_struct.ObjectsLabel;
image_data=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
set(msr_gui_struct.ImageHandle,'CData',image_data);
if (button_value==1)
    %toggle select object button off
    set(msr_gui_struct.SelectObjectButtonHandle,'Value',0);
    %disable object action buttons
    set(msr_gui_struct.JoinObjectsButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveObjectButtonHandle,'Enable','off');
    %enable blob action buttons
    set(msr_gui_struct.ResegmentBlobButtonHandle,'Enable','on');
    set(msr_gui_struct.RemoveBlobButtonHandle,'Enable','on');
    set(msr_gui_struct.RestoreBlobButtonHandle,'Enable','on');
    updateReviewSegGUIStatus('SelectBlob');
    msr_gui_struct.SelectedObjectID=[];    
else
    %disable blob action buttons
    set(msr_gui_struct.ResegmentBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RestoreBlobButtonHandle,'Enable','off');
    msr_gui_struct.CurrentAction='';
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.SelectedObjectID=[];
    updateReviewSegGUIStatus('InitialStatus');
end

%end selectBlobButtonPressed
end