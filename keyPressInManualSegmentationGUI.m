function keyPressInManualSegmentationGUI()
global msr_gui_struct;

switch (msr_gui_struct.CurrentAction)
    case 'ResegmentBlob'
        gui_handle=msr_gui_struct.GuiHandle;
        char_pressed=get(gui_handle,'CurrentCharacter');
        if (char_pressed=='d')
            resegmentBlob('complete');
        elseif (char_pressed=='q')
            msr_gui_struct.CurrentAction='SelectBlob';
        elseif (char_pressed=='n')
            msr_gui_struct.CurrentResegmentationIndex=msr_gui_struct.CurrentResegmentationIndex+1;
        end
    otherwise
        return;
end

%end keyPressInManualSegmentationGUI
end