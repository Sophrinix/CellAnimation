function invertSelection()
%helper function for manual segmentation review GUI. used to select the
%objects not currently selected
global msr_gui_struct;

switch (msr_gui_struct.CurrentAction)
    case 'SelectBlob'
        selected_ids=msr_gui_struct.SelectedBlobID;        
        cur_lbl=msr_gui_struct.BlobsLabel;
    case 'SelectObject'
        selected_ids=msr_gui_struct.SelectedObjectIDs;
        cur_lbl=msr_gui_struct.ObjectsLabel;
    otherwise
        return;
end

unique_ids=unique(cur_lbl(:));
unique_ids(1)=[];
inverse_idx=~(ismember(unique_ids,selected_ids));
inverse_ids=unique_ids(inverse_idx);
selection_idx=ismember(cur_lbl,inverse_ids);
selection_mask=repmat(selection_idx,[1 1 3]);
image_data=label2rgb(msr_gui_struct.ObjectsLabel,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle');
image_data(selection_mask)=createCheckerBoardPattern(selection_idx);
set(msr_gui_struct.ImageHandle,'CData',image_data);

switch (msr_gui_struct.CurrentAction)
    case 'SelectBlob'
        msr_gui_struct.SelectedBlobID=inverse_ids;        
    case 'SelectObject'
        msr_gui_struct.SelectedObjectIDs=inverse_ids;       
end

%end invertSelection
end