function addSegmentationError(error_type, original_blob_id)
%helper function for the manual segmentation review GUI. Used to add a
%segmentation error to the list of segmentation errors.
global msr_gui_struct;

error_blob_ids=msr_gui_struct.ErrorBlobIDs;
other_errors_idx=(error_blob_ids==original_blob_id);
other_errors_nr=sum(other_errors_idx);
if (other_errors_nr)
    if (strcmp(error_type,'BlobThresholding'))
        %we are deleting this blob so remove all other errors associated with
        %it
        msr_gui_struct.TotalErrors=msr_gui_struct.TotalErrors-other_errors_nr+1;
        error_types=msr_gui_struct.ErrorTypes;
        error_types(other_errors_idx)=[];        
        msr_gui_struct.ErrorTypes=[error_types; {error_type}];
        error_blob_ids(other_errors_idx)=[];
        msr_gui_struct.ErrorBlobIDs=[error_blob_ids; original_blob_id];        
    end
    if (strcmp(error_type,'Undersegmentation')||strcmp(error_type,'Oversegmentation')||...
            strcmp(error_type,'Distribution'))
        error_types=msr_gui_struct.ErrorTypes;
        error_types{other_errors_idx}=error_type;
        msr_gui_struct.ErrorTypes=error_types;        
    end
else
    msr_gui_struct.TotalErrors=msr_gui_struct.TotalErrors+1;
    msr_gui_struct.ErrorTypes=[msr_gui_struct.ErrorTypes; {error_type}];
    msr_gui_struct.ErrorBlobIDs=[error_blob_ids; original_blob_id];
end

%end addSegmentationError
end