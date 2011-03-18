function enableMultipleSelection()
%helper function for manual segmentation review module. 
global msr_gui_struct;
msr_gui_struct.SelectMultiple=get(msr_gui_struct.CheckBoxSelectMultipleHandle,'Value');

end