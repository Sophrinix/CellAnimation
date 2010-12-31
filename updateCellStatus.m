function []=updateCellStatus()
%helper function for the manual tracking review gui. used to update the properties of the
%selected cell

global mtr_gui_struct;

num_fmt='%1.2f';

ancestry_layout=mtr_gui_struct.AncestryLayout;
tracks_layout=mtr_gui_struct.TracksLayout;
cell_track_record=mtr_gui_struct.CurrentTrackRecord;
cell_id=mtr_gui_struct.SelectedCellID;
cell_ancestry_record=mtr_gui_struct.CurrentAncestryRecord;
status_text=['Cell ID: ' num2str(cell_id) ' \n'];
parent_id=cell_ancestry_record(ancestry_layout.ParentIDCol);
status_text=[status_text 'Parent ID: ' num2str(parent_id) ' \n'];
start_frame=(cell_ancestry_record(ancestry_layout.StartTimeCol)./mtr_gui_struct.TimeFrame)+1;
status_text=[status_text 'Start Frame: ' num2str(start_frame) ' \n'];
end_frame=(cell_ancestry_record(ancestry_layout.StopTimeCol)./mtr_gui_struct.TimeFrame)+1;
status_text=[status_text 'End Frame: ' num2str(end_frame) ' \n'];
cell_generation=cell_ancestry_record(ancestry_layout.GenerationCol);
status_text=[status_text 'Generation: ' num2str(cell_generation) ' \n'];
cell_area=cell_track_record(tracks_layout.AreaCol);
status_text=[status_text 'Area: ' num2str(cell_area,num_fmt) ' \n'];
cell_ecc=cell_track_record(tracks_layout.EccCol);
status_text=[status_text 'Eccentricity: ' num2str(cell_ecc,num_fmt) ' \n'];
cell_mal=cell_track_record(tracks_layout.MalCol);
status_text=[status_text 'Major Axis Length: ' num2str(cell_mal,num_fmt) ' \n'];
cell_mil=cell_track_record(tracks_layout.MilCol);
status_text=[status_text 'Minor Axis Length: ' num2str(cell_mil,num_fmt) ' \n'];
cell_ori=cell_track_record(tracks_layout.OriCol);
status_text=[status_text 'Orientation: ' num2str(cell_ori,num_fmt) ' \n'];
cell_per=cell_track_record(tracks_layout.PerCol);
status_text=[status_text 'Perimeter: ' num2str(cell_per,num_fmt) ' \n'];
cell_sol=cell_track_record(tracks_layout.SolCol);
status_text=[status_text 'Solidity: ' num2str(cell_sol,num_fmt) ' \n'];
status_text=sprintf(status_text);
cell_speed=mtr_gui_struct.CurrentSpeed;
status_text=[status_text 'Speed: ' num2str(cell_speed,num_fmt) ' \n'];
status_text=sprintf(status_text);
cell_sq_disp=mtr_gui_struct.CurrentSquareDisplacement;
status_text=[status_text 'Square Displacement: ' num2str(cell_sq_disp,num_fmt) ' \n'];
status_text=sprintf(status_text);
set(mtr_gui_struct.EditCellStatusHandle,'String',status_text);

%end updateCellStatus
end