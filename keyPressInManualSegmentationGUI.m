function keyPressInManualSegmentationGUI()
%helper function in manual segmentation review GUI. detect key presses and
%take various actions
global msr_gui_struct;
gui_handle=msr_gui_struct.GuiHandle;
char_pressed=get(gui_handle,'CurrentCharacter');

switch (msr_gui_struct.CurrentAction)
    case 'ResegmentBlob'        
        if (char_pressed=='d')
            resegmentBlob('complete');
        elseif (char_pressed=='q')
            msr_gui_struct.CurrentAction='SelectBlob';
        elseif (char_pressed=='n')
            msr_gui_struct.CurrentResegmentationIndex=msr_gui_struct.CurrentResegmentationIndex+1;
        end
    case 'JoinObjects'
        if (char_pressed=='d')
            joinObjects('complete');
        end
    otherwise
        return;
end

%end keyPressInManualSegmentationGUI
end