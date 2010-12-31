function addSplit()
%helper function for the manual tracking review module. used to initiate a
%track split
global mtr_gui_struct;

mtr_gui_struct.TrackToSplitID=mtr_gui_struct.SelectedCellID;
mtr_gui_struct.TrackToSplitRecord=mtr_gui_struct.CurrentTrackRecord;
mtr_gui_struct.TrackToSplitAncestry=mtr_gui_struct.CurrentAncestryRecord;
mtr_gui_struct.SplitTrack=true;

%end addSplit
end