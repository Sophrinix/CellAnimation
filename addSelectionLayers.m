function addSelectionLayers()
%helper function for the manual tracking review module. Used to overlay
%selection layers over the original image
global mtr_gui_struct;

selection_layers=mtr_gui_struct.SelectionLayers;
layers_nr=length(selection_layers);
if (layers_nr==0)
    return;
end
layer_transparency=1./(layers_nr+1);
ancestry_records=mtr_gui_struct.CellsAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
%sort frame ancestries and tracks so we can use ismember to pick instead of
%loops
frame_tracks=mtr_gui_struct.FrameTracks;
tracks_layout=mtr_gui_struct.TracksLayout;
[dummy sort_idx]=sort(frame_tracks(:,tracks_layout.TrackIDCol));
mtr_gui_struct.FrameTracks=frame_tracks(sort_idx,:);
%get the ancestry records for the cells in the frame
cell_ids=frame_tracks(:,tracks_layout.TrackIDCol);
%this works because both are sorted and unique
frame_ancestries_idx=ismember(ancestry_records(:,ancestry_layout.TrackIDCol),cell_ids);
frame_ancestries=ancestry_records(frame_ancestries_idx,:);
[dummy sort_idx]=sort(frame_ancestries(:,ancestry_layout.TrackIDCol));
mtr_gui_struct.FrameAncestries=frame_ancestries(sort_idx,:);
cell_speeds=mtr_gui_struct.CellSpeeds;
cur_speeds_idx=cell_speeds(:,3)==((mtr_gui_struct.CurFrame-1).*mtr_gui_struct.TimeFrame);
[dummy sort_idx]=sort(cell_speeds(cur_speeds_idx,1));
frame_speeds=cell_speeds(cur_speeds_idx,:);
mtr_gui_struct.FrameSpeeds=frame_speeds(sort_idx,2);
cell_sq_disps=mtr_gui_struct.CellSquareDisplacements;
cur_sq_disps_idx=cell_sq_disps(:,3)==((mtr_gui_struct.CurFrame-1).*mtr_gui_struct.TimeFrame);
[dummy sort_idx]=sort(cell_sq_disps(cur_sq_disps_idx,1));
frame_sq_disps=cell_sq_disps(cur_sq_disps_idx,:);
mtr_gui_struct.FrameSquareDisplacements=frame_sq_disps(sort_idx,2);
existing_red_color=[];
existing_green_color=[];
existing_blue_color=[];

for i=1:layers_nr
    [red_color green_color blue_color]=addSelectionLayer(selection_layers{i},...
        existing_red_color,existing_green_color,existing_blue_color);
    existing_red_color=red_color;
    existing_green_color=green_color;
    existing_blue_color=blue_color;
end

hold off;
mtr_gui_struct.ImageHandle=image(mtr_gui_struct.ImageData,'Parent',mtr_gui_struct.TracksHandle);
hold on;
mtr_gui_struct.ImageHandle=image(cat(3,red_color,green_color,blue_color),'Parent',mtr_gui_struct.TracksHandle);
set(mtr_gui_struct.ImageHandle,'AlphaData',0.5);
%set the function handle for a mouse click in the objects image
set(mtr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInTrackingFrame');
hold off;

%end addSelectionLayers
end

function [red_color green_color blue_color]=addSelectionLayer(selection_layer,...
    existing_red_color,existing_green_color,existing_blue_color)
global mtr_gui_struct;

selected_ids=getCellsInSelectionLayer(selection_layer);
label_ids=getSelectedCellsLabelIDs(selected_ids);
cells_lbl=mtr_gui_struct.CellsLabel;
lbl_sz=size(cells_lbl);
selected_cells_mask=ismember(cells_lbl,label_ids);
max_pxl=intmax('uint8');
rgb_triple=getRGBTriple(selection_layer.Color);
if isempty(existing_red_color)
    red_color=(max_pxl.*rgb_triple(1).*uint8(selected_cells_mask));
else
    red_color_mask=existing_red_color>0;
    red_color=zeros(lbl_sz,'uint8');
    intersect_mask=red_color_mask & selected_cells_mask;
    new_red_color=(max_pxl.*rgb_triple(1).*uint8(selected_cells_mask));
    red_color(~intersect_mask)=existing_red_color(~intersect_mask)+new_red_color(~intersect_mask);
    red_color(intersect_mask)=existing_red_color(intersect_mask)./2+new_red_color(intersect_mask)./2;
end
if isempty(existing_green_color)
    green_color=(max_pxl.*rgb_triple(2).*uint8(selected_cells_mask));
else
    green_color_mask=existing_green_color>0;
    green_color=zeros(lbl_sz,'uint8');
    intersect_mask=green_color_mask & selected_cells_mask;
    new_green_color=(max_pxl.*rgb_triple(2).*uint8(selected_cells_mask));
    green_color(~intersect_mask)=existing_green_color(~intersect_mask)+new_green_color(~intersect_mask);
    green_color(intersect_mask)=existing_green_color(intersect_mask)./2+new_green_color(intersect_mask)./2;
end
if isempty(existing_blue_color)
    blue_color=(max_pxl.*rgb_triple(3).*uint8(selected_cells_mask));
else
    blue_color_mask=existing_blue_color>0;
    blue_color=zeros(lbl_sz,'uint8');
    intersect_mask=blue_color_mask & selected_cells_mask;
    new_blue_color=(max_pxl.*rgb_triple(3).*uint8(selected_cells_mask));
    blue_color(~intersect_mask)=existing_blue_color(~intersect_mask)+new_blue_color(~intersect_mask);
    blue_color(intersect_mask)=existing_blue_color(intersect_mask)./2+new_blue_color(intersect_mask)./2;
end

%end addSelectionLayer
end

function rgb_triple=getRGBTriple(color_string)

switch color_string
    case 'Aquamarine'
        rgb_triple=[0.4980;1.0000;0.8314];
    case 'Black'
        rgb_triple=[0.0;0.0;0.0];
    case 'Dark Brown'
        rgb_triple=[0.3608;0.2510;0.2000];
    case 'Blue'
        rgb_triple=[0.0;0.0;1.0];
    case 'Dark Green'
        rgb_triple=[0.0;0.3922;0];
    case 'Lime Green'
        rgb_triple=[0.1961;0.8039;0.1961];
    case 'Grey'
        rgb_triple=[0.3294;0.3294;0.3294];
    case 'Orange'
        rgb_triple=[1.0000;0.6471;0.0];
    case 'Pink'
        rgb_triple=[1.0000;0.7529;0.7961];
    case 'Purple'
        rgb_triple=[0.6275;0.1255;0.9412];
    case 'Red'
        rgb_triple=[1.0;0.0;0.0];
    case 'Sienna'
        rgb_triple=[0.6275;0.3216;0.1765];
    case 'Turqoise'
        rgb_triple=[0.2510;0.8784;0.8157];
    case 'Violet'
        rgb_triple=[0.9333;0.5098;0.9333];
    case 'Yellow'
        rgb_triple=[1.0;1.0;0.0];
end

%end getRGBTriple
end

function selected_ids=getCellsInSelectionLayer(selection_layer)
global mtr_gui_struct;

layer_conditions=selection_layer.Conditions;
frame_tracks=mtr_gui_struct.FrameTracks;
frame_ancestries=mtr_gui_struct.FrameAncestries;
frame_speeds=mtr_gui_struct.FrameSpeeds;
frame_sq_disps=mtr_gui_struct.FrameSquareDisplacements;
tracks_layout=mtr_gui_struct.TracksLayout;
ancestry_layout=mtr_gui_struct.AncestryLayout;
cell_ids=frame_tracks(:,tracks_layout.TrackIDCol);
selection_idx=true(length(cell_ids),1);

for i=1:length(layer_conditions)
    cur_condition=layer_conditions(i);
    switch(cur_condition.ComboCellProperty)
        case 'Area'
            property_vals=frame_tracks(:,tracks_layout.AreaCol);            
        case 'Cell ID'
            property_vals=cell_ids;
        case 'Generation'
            property_vals=frame_ancestries(:,ancestry_layout.GenerationCol);
        case 'Eccentricity'
            property_vals=frame_tracks(:,tracks_layout.EccCol);
        case 'End Frame'
            property_vals=frame_ancestries(:,ancestry_layout.StopTimeCol);
        case 'Speed'
            property_vals=frame_speeds;
        case 'Start Frame'
            property_vals=frame_ancestries(:,ancestry_layout.StartTimeCol);
        case 'Parent ID'
            property_vals=frame_ancestries(:,ancestry_layout.ParentIDCol);
        case 'Perimeter'
            property_vals=frame_tracks(:,tracks_layout.PerCol);
        case 'RMS'
            property_vals=frame_sq_disps;
        case 'Solidity'
            property_vals=frame_tracks(:,tracks_layout.SolCol);
    end
    
    edit_val=cur_condition.EditValue; 
    if(edit_val(end)=='%')
        b_pct=true;
        [dummy sort_idx]=sort(property_vals);
        nr_of_vals=length(property_vals);
        select_pct=str2num(edit_val(1:(end-1)))/100;
        new_selection_idx=false(nr_of_vals,1);
    else
        b_pct=false;
        threshold_val=str2double(edit_val);
    end
                
    switch cur_condition.ComboOperator
        case '='
            if (b_pct)
                selection_idx=ceil(select_pct.*nr_of_vals);
                new_selection_idx(sort_idx(selection_idx))=true;                
            else                
                new_selection_idx=property_vals==threshold_val;
                selected_ids=cell_ids(selection_idx);
            end
        case '>'
            if (b_pct)
                nr_selected_vals=ceil((1-select_pct).*nr_of_vals);                
                new_selection_idx(sort_idx((end-nr_selected_vals+1):end))=true;                
            else                
                new_selection_idx=property_vals>threshold_val;                
            end            
        case '<'
            if (b_pct)                
                nr_selected_vals=ceil((1-select_pct).*nr_of_vals);                                
                new_selection_idx(sort_idx(1:nr_selected_vals))=true;
            else
                new_selection_idx=property_vals<threshold_val;                
            end
    end
    switch cur_condition.ComboLogicConnector
        case 'AND'
            selection_idx=selection_idx & new_selection_idx;
        case 'OR'
            selection_idx=selection_idx | new_selection_idx;
    end    
end
selected_ids=cell_ids(selection_idx);

%end getSelectionID
end

function label_ids=getSelectedCellsLabelIDs(selected_ids)
global mtr_gui_struct;

if (isempty(selected_ids))
    label_ids=[];
    return;
end

tracks_layout=mtr_gui_struct.TracksLayout;
frame_tracks=mtr_gui_struct.FrameTracks;
selected_cells_nr=length(selected_ids);
label_ids=zeros(selected_cells_nr,1);

for i=1:length(selected_ids)
    cur_track_record=frame_tracks(frame_tracks(:,tracks_layout.TrackIDCol)==selected_ids(i),:);
    cell_centroid=cur_track_record(:,tracks_layout.Centroid1Col:tracks_layout.Centroid2Col);
    cur_centroids=mtr_gui_struct.CurCentroids;
    cur_dist=hypot(cell_centroid(1)-cur_centroids(:,1),cell_centroid(2)-cur_centroids(:,2));
    [dummy label_ids(i)]=min(cur_dist);    
end

%end getSelectedCellsLabelIDs
end