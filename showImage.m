function showImage()
%helper function for manual segmentation review module. display the image
%of the current label matrix
global msr_gui_struct;
show_image=get(msr_gui_struct.CheckBoxImageHandle,'Value');
if (show_image)
    %toggle select blob button off
    set(msr_gui_struct.SelectBlobButtonHandle,'Enable','off');
    %toggle select object button off
    set(msr_gui_struct.SelectObjectButtonHandle,'Enable','off');
    %disable blob action buttons
    set(msr_gui_struct.ResegmentBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RestoreBlobButtonHandle,'Enable','off');
    %disable object action buttons
    set(msr_gui_struct.JoinObjectsButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveObjectButtonHandle,'Enable','off');
    %disable show raw label checkbox
    set(msr_gui_struct.CheckBoxRawLabelHandle,'Enable','off');
    %disable show previous label checkbox
    set(msr_gui_struct.CheckBoxPrevLabelHandle,'Enable','off');
    %save selections
    msr_gui_struct.SavedAction=msr_gui_struct.CurrentAction;
    field_names=fieldnames(msr_gui_struct);
    if (max(strcmp(field_names,'SelectedBlobID')))
        msr_gui_struct.SavedBlobID=msr_gui_struct.SelectedBlobID;        
    else
        msr_gui_struct.SavedBlobID=[];
    end
    if (max(strcmp(field_names,'SavedObjectID')))
        msr_gui_struct.SavedObjectID=msr_gui_struct.SelectedObjectID;        
    else
        msr_gui_struct.SavedObjectID=[];
    end    
    msr_gui_struct.CurrentAction='ShowImage';
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.SelectedObjectID=[];
    %show previous label
    colormap(gray);
    msr_gui_struct.ImageHandle=imagesc(msr_gui_struct.Image,'Parent',msr_gui_struct.AxesHandle);   
else
    cur_action=msr_gui_struct.SavedAction;
    msr_gui_struct.CurrentAction=cur_action;
    %toggle select blob button on
    set(msr_gui_struct.SelectBlobButtonHandle,'Enable','on');
    %toggle select object button on
    set(msr_gui_struct.SelectObjectButtonHandle,'Enable','on');
    %enable show raw label checkbox
    set(msr_gui_struct.CheckBoxRawLabelHandle,'Enable','on');
    %enable show raw label checkbox
    set(msr_gui_struct.CheckBoxPrevLabelHandle,'Enable','on');        
    %show current label
    objects_lbl=msr_gui_struct.ObjectsLabel;    
    objects_lbl_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    msr_gui_struct.ImageHandle=image(objects_lbl_rgb,'Parent',msr_gui_struct.AxesHandle);
    msr_gui_struct.CurrentAction=msr_gui_struct.SavedAction;
    blob_id=msr_gui_struct.SavedBlobID;
    switch(cur_action)
        case 'SelectBlob'
            %enable blob action buttons
            set(msr_gui_struct.ResegmentBlobButtonHandle,'Enable','on');
            set(msr_gui_struct.RemoveBlobButtonHandle,'Enable','on');
            set(msr_gui_struct.RestoreBlobButtonHandle,'Enable','on');
            updateReviewSegGUIStatus('SelectBlob');
        case 'SelectObject'
            %enable object action buttons
            set(msr_gui_struct.JoinObjectsButtonHandle,'Enable','on');
            set(msr_gui_struct.RemoveObjectButtonHandle,'Enable','on');
            updateReviewSegGUIStatus('SelectObject');
    end
    if (~isempty(blob_id))
        msr_gui_struct.SelectedBlobID=blob_id;
        selectBlobByID(blob_id);        
    end
    obj_id=msr_gui_struct.SavedObjectID;
    if (~isempty(obj_id))
        msr_gui_struct.SelectedObjectID=obj_id;
        selectObjectByID(obj_id);        
    end
    msr_gui_struct.SavedAction=[];
    msr_gui_struct.SavedBlobID=[];
    msr_gui_struct.SavedObjectID=[];    
    %set the function handle for a mouse click in the objects image
    set(msr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInLabel');
    set(msr_gui_struct.GuiHandle,'KeyPressFcn','keyPressInManualSegmentationGUI');
end

%end showImage
end