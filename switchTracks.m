function switchTracks()
%helper for manual tracking review module. initialize switch track
%process
global mtr_gui_struct;

mtr_gui_struct.SwitchTrackID=mtr_gui_struct.SelectedCellID;
mtr_gui_struct.SwitchTrackRecord=mtr_gui_struct.CurrentTrackRecord;
mtr_gui_struct.SwitchTrackAncestry=mtr_gui_struct.CurrentAncestryRecord;
mtr_gui_struct.SwitchTrack=true;

%end switchTracks
end