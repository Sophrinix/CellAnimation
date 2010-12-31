function selectCell(cur_cell_lbl_id)
%helper function for manual tracking review module. used to select a cell
%in the GUI
global mtr_gui_struct;

cells_lbl=mtr_gui_struct.CellsLabel;
cur_cell=(cells_lbl==cur_cell_lbl_id);
max_pxl=intmax('uint8');
%check if we're dealing with a fragmented cell
cur_cell_lbl=bwlabeln(cur_cell);
if max(cur_cell_lbl(:)>1)    
    cur_cell=joinFragmentedBlob(cur_cell);
end
mtr_gui_struct.CurCellBlob=cur_cell;

%end selectCell
end