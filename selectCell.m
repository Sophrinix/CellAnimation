function selectCell(cur_cell_lbl_id)
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
%create a red color image of the cell shape
img_sz=size(cur_cell);
red_color=max_pxl.*uint8(cur_cell);
green_color=zeros(img_sz);
blue_color=zeros(img_sz);
hold off;
mtr_gui_struct.ImageHandle=image(mtr_gui_struct.ImageData,'Parent',mtr_gui_struct.TracksHandle);
hold on;
mtr_gui_struct.ImageHandle=image(cat(3,red_color,green_color,blue_color),'Parent',mtr_gui_struct.TracksHandle);
set(mtr_gui_struct.ImageHandle,'AlphaData',0.3);
%set the function handle for a mouse click in the objects image
set(mtr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInTrackingFrame');

%end selectCell
end