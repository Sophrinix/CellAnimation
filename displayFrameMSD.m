function displayFrameMSD()
%internal function for the manual tracking review GUI. It displays the
%mean square displacement for all the cells in the frame.

global mtr_gui_struct;

frame_msds=mtr_gui_struct.FrameMSDs;
averages_text=[mtr_gui_struct.AveragesText ' Frame MSD ' num2str(frame_msds(mtr_gui_struct.CurFrame),'%1.2f')];
set(mtr_gui_struct.AveragesTextHandle,'String',averages_text);

%end displayFrameMSD
end