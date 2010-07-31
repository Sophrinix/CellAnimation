function displayFrameMSD()
global mtr_gui_struct;

frame_msds=mtr_gui_struct.FrameMSDs;
averages_text=[mtr_gui_struct.AveragesText ' Frame MSD ' num2str(frame_msds(mtr_gui_struct.CurFrame))];
set(mtr_gui_struct.AveragesTextHandle,'String',averages_text);

%end displayFrameMSD
end