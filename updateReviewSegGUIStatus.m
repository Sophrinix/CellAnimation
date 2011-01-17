function updateReviewSegGUIStatus(gui_status)
%helper function for manual segmentation review. update the GUI status bar
global msr_gui_struct;
status_text_handle=msr_gui_struct.StatusTextHandle;

switch (gui_status)
    case 'InitialStatus'
        msr_gui_struct.CurrentAction='';
        set(status_text_handle,'String','Click on "Select Blob" or "Select Object" to begin.');
    case 'JoinObjects'
        msr_gui_struct.CurrentAction='JoinObjects';
        set(status_text_handle,'String','Click on objects to be joined. Click again to remove them from the join list. Type "d" when done.');
    case 'SelectBlob'
        msr_gui_struct.CurrentAction='SelectBlob';        
        set(status_text_handle,'String','Click on a blob to select it.');
    case 'SelectObject'
        msr_gui_struct.CurrentAction='SelectObject';        
        set(status_text_handle,'String','Click on an object to select it.');
    case 'ResegmentBlob'
        msr_gui_struct.CurrentAction='ResegmentBlob';
        set(status_text_handle,'String',...
            'Click on points inside an object (minimum one) then type "n" to select points inside the next object. Type "d" when done.');
end
        

%end updateReviewSegGUIStatus
end