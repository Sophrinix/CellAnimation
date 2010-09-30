function overlayPreviousLabel()

global msr_gui_struct;
overlay_prev_label=get(msr_gui_struct.CheckBoxOverlayPrevLabelHandle,'Value');
if (overlay_prev_label)    
    prev_label=msr_gui_struct.PreviousLabel;
    prev_label_layer=prev_label>0;    
    image_overlay=repmat(intmax('uint8')*uint8(prev_label_layer),[1 1 3]);
    image_data=get(msr_gui_struct.ImageHandle,'CData');    
    mtr_gui_struct.ImageHandle=imagesc(image_data,'Parent',msr_gui_struct.AxesHandle);
    hold on;
    msr_gui_struct.ImageHandle=image(image_overlay,'Parent',msr_gui_struct.AxesHandle);    
    set(msr_gui_struct.ImageHandle,'AlphaData',0.3);
    hold off;
    %set the function handle for a mouse click in the objects image
    set(msr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInLabel');
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
else
    %toggle select blob button off
    set(msr_gui_struct.SelectBlobButtonHandle,'Enable','on');
    %toggle select object button off
    set(msr_gui_struct.SelectObjectButtonHandle,'Enable','on');      
    switch msr_gui_struct.CurrentAction
        case 'ShowImage'
            objects_rgb=msr_gui_struct.Image;
        case 'ShowPreviousLabel'
            prev_label=msr_gui_struct.PreviousLabel;
            objects_rgb=label2rgb(prev_label,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');           
        case 'ShowRawLabel'
            raw_label=msr_gui_struct.OriginalObjectsLabel;
            objects_rgb=label2rgb(raw_label,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');                        
        otherwise
            cur_label=msr_gui_struct.ObjectsLabel;
            objects_rgb=label2rgb(cur_label,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');            
    end
    msr_gui_struct.ImageHandle=imagesc(objects_rgb,'Parent',msr_gui_struct.AxesHandle);
    %set the function handle for a mouse click in the objects image
    set(msr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInLabel'); 
end

%end overlayPreviousLabel
end