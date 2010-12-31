function continueTrack()
%helper function for the manual tracking review module. use to start the
%process of continuing a track
global mtr_gui_struct;

mtr_gui_struct.TrackToContinueID=mtr_gui_struct.SelectedCellID;
mtr_gui_struct.TrackToContinueRecord=mtr_gui_struct.CurrentTrackRecord;
mtr_gui_struct.TrackToContinueAncestry=mtr_gui_struct.CurrentAncestryRecord;
mtr_gui_struct.ContinueTrack=true;

%end continueTrack
end