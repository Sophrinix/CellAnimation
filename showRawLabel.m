function showRawLabel()
%helper function for manual segmentation review module. show the original
%label without any corrections
global msr_gui_struct;
show_raw_label=get(msr_gui_struct.CheckBoxRawLabelHandle,'Value');
if (show_raw_label)
    %toggle select blob button on
    set(msr_gui_struct.SelectBlobButtonHandle,'Enable','off');
    %toggle select object button on
    set(msr_gui_struct.SelectObjectButtonHandle,'Enable','off');
    %disable blob action buttons
    set(msr_gui_struct.ResegmentBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveBlobButtonHandle,'Enable','off');
    set(msr_gui_struct.RestoreBlobButtonHandle,'Enable','off');
    %disable object action buttons
    set(msr_gui_struct.JoinObjectsButtonHandle,'Enable','off');
    set(msr_gui_struct.RemoveObjectButtonHandle,'Enable','off');
    %disable show previous label checkbox
    set(msr_gui_struct.CheckBoxPrevLabelHandle,'Enable','off'); 
    %disable show image checkbox
    set(msr_gui_struct.CheckBoxImageHandle,'Enable','off');
    %remove selections
    msr_gui_struct.CurrentAction='ShowRawLabel';
    msr_gui_struct.SelectedBlobID=[];
    msr_gui_struct.SelectedObjectID=[];
    %show previous label
    raw_label=msr_gui_struct.OriginalObjectsLabel;
    raw_label_rgb=label2rgb(raw_label,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    msr_gui_struct.ImageHandle=image(raw_label_rgb,'Parent',msr_gui_struct.AxesHandle);
else
    %toggle select blob button off
    set(msr_gui_struct.SelectBlobButtonHandle,'Enable','on');
    %toggle select object button off
    set(msr_gui_struct.SelectObjectButtonHandle,'Enable','on');
    %enable show previous label checkbox
    set(msr_gui_struct.CheckBoxPrevLabelHandle,'Enable','on');
    %enable show image checkbox
    set(msr_gui_struct.CheckBoxImageHandle,'Enable','on');    
    %show current label
    objects_lbl=msr_gui_struct.ObjectsLabel;    
    objects_lbl_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
    msr_gui_struct.ImageHandle=image(objects_lbl_rgb,'Parent',msr_gui_struct.AxesHandle);
    msr_gui_struct.CurrentAction='';
    %set the function handle for a mouse click in the objects image
    set(msr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInLabel');
    set(msr_gui_struct.GuiHandle,'KeyPressFcn','keyPressInManualSegmentationGUI');
end

%end showPreviousLabel
end