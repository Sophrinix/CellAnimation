function undoAllChanges(hObject, eventdata, handles)
global msr_gui_struct;

button_pressed=questdlg('Are you sure you want to undo all the changes?',...
    'Undo Segmentation Changes','Yes','No','No');
switch(button_pressed)
    case 'Yes'
        objects_lbl=msr_gui_struct.OriginalObjectsLabel;
        msr_gui_struct.ObjectsLabel=objects_lbl;
        msr_gui_struct.BlobsLabel=bwlabeln(objects_lbl);
        msr_gui_struct.ErrorTypes=[];
        msr_gui_struct.ErrorBlobIDs=[];
        msr_gui_struct.TotalErrors=0;
        image_handle=msr_gui_struct.ImageHandle;
        image_data=label2rgb(objects_lbl);
        set(image_handle,'CData',image_data);
    case 'No'
        return;
end

%end undoAllChanges
end