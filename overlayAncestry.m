function output_args=overlayAncestry(input_args)
%Usage
%This module is used to overlay the cell outlines (color-coded according to generation number)
%and the track ids on top of the original cell image.
%
%Input Structure Members
%AncestryLayout – Matrix describing the order of the columns in the ancestry matrix.
%CurrentTracks – The set of tracks for the current image.
%CellsLabel – The label matrix containing the detected cell shapes for the current image.
%CellsAncestry – Matrix containing the ancestry records for the cells in the time-lapse movie.
%ColorMap – Color map to be used in drawing the cell outlines for each generation. Each
%generation will use the next color in the color map until all colors have been used. Afterwards,
%the colors in the map are recycled.
%Image – This is the original cell image.
%ShowLabels – Boolean value. If set to false the cell IDs will not be overlayed.
%ShowOutlines – Boolean value. If set to false the cell outlines will not be overlayed.
%TracksLayout – Matrix describing the order of the columns in the tracks matrix.
%
%Output Structure Members
%Image – The overlayed image.
%
%Example
%
%overlay_ancestry_args.Image.Value=img;
%overlay_ancestry_args.CurrentTracks.Value=cur_tracks_struct.Tracks;
%overlay_ancestry_args.CellsLabel.Value=label_struct.cells_lbl;
%overlay_ancestry_args.CellsAncestry.Value=mtr_gui_struct.CellsAncestry;
%overlay_ancestry_args.CurFrame.Value=frame_nr;
%overlay_ancestry_args.ColorMap.Value=mtr_gui_struct.ColorMap;
%overlay_ancestry_args.TracksLayout.Value=mtr_gui_struct.TracksLayout;
%overlay_ancestry_args.AncestryLayout.Value=mtr_gui_struct.AncestryLayout;
%overlay_ancestry_args.ShowLabels.Value=b_show_labels;
%overlay_ancestry_args.ShowOutlines.Value=b_show_outlines;
%overlay_ancestry_struct=overlayAncestry(overlay_ancestry_args);

cur_img=input_args.Image.Value;
cur_tracks=input_args.CurrentTracks.Value;
cells_lbl=input_args.CellsLabel.Value;
cells_ancestry=input_args.CellsAncestry.Value;
cmap=input_args.ColorMap.Value;

img_sz=size(cur_img);
max_pxl=intmax('uint8');
imnorm_args.IntegerClass.Value='uint8';
imnorm_args.RawImage.Value=cur_img;
imnorm_output=imNorm(imnorm_args);
cur_img=imnorm_output.Image;
red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

tracks_layout=input_args.TracksLayout.Value;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

ancestry_layout=input_args.AncestryLayout.Value;
ancestryIDCol=ancestry_layout.TrackIDCol;
generationCol=ancestry_layout.GenerationCol;
b_show_labels=input_args.ShowLabels.Value;
b_show_outlines=input_args.ShowOutlines.Value;

cur_cell_number=size(cur_tracks,1);

if (b_show_outlines)
    %i need to get the outlines of each individual cell since more than one
    %cell might be in a blob
    avg_filt=fspecial('average',[3 3]);
    lbl_avg=imfilter(cells_lbl,avg_filt,'replicate');
    lbl_avg=double(lbl_avg).*double(cells_lbl>0);
    img_bounds=abs(double(cells_lbl)-lbl_avg);
    img_bounds=img_bounds>0.1;
    bounds_lbl=zeros(img_sz);
    bounds_lbl(img_bounds)=cells_lbl(img_bounds);
    
    %draw the cell boundaries
    for j=1:cur_cell_number
        cur_centroid=cur_tracks(j,centroid1Col:centroid2Col);
        cell_id=cur_tracks(j,trackIDCol);
        cell_lbl_id=getLabelId(cells_lbl,cur_centroid);
        cell_generation=cells_ancestry(cells_ancestry(:,ancestryIDCol)==cell_id,generationCol);
        cell_bounds_idx=(bounds_lbl==cell_lbl_id);
        %draw in the red channel
        red_color(cell_bounds_idx)=max_pxl*cmap(cell_generation,1);
        green_color(cell_bounds_idx)=max_pxl*cmap(cell_generation,2);
        blue_color(cell_bounds_idx)=max_pxl*cmap(cell_generation,3);
    end
end

if (b_show_labels)
    %draw the cell labels
    for j=1:cur_cell_number
        cur_centroid=cur_tracks(j,centroid1Col:centroid2Col);
        cell_id=cur_tracks(j,trackIDCol);
        
        text_img=text2im(num2str(cell_id));
        text_img=imresize(text_img,0.75,'nearest');
        text_length=size(text_img,2);
        text_height=size(text_img,1);
        rect_coord_1=round(cur_centroid(1)-text_height/2);
        rect_coord_2=round(cur_centroid(1)+text_height/2);
        rect_coord_3=round(cur_centroid(2)-text_length/2);
        rect_coord_4=round(cur_centroid(2)+text_length/2);
        if ((rect_coord_1<1)||(rect_coord_2>img_sz(1))||(rect_coord_3<1)||(rect_coord_4>img_sz(2)))
            continue;
        end
        [text_coord_1 text_coord_2]=find(text_img==0);
        %offset the text coordinates by the image coordinates in the (low,low)
        %corner of the rectangle
        text_coord_1=text_coord_1+rect_coord_1;
        text_coord_2=text_coord_2+rect_coord_3;
        text_coord_lin=sub2ind(img_sz,text_coord_1,text_coord_2);
        %write the text in green
        red_color(text_coord_lin)=0;
        green_color(text_coord_lin)=max_pxl;
        blue_color(text_coord_lin)=0;
    end
end

output_args.Image=cat(3,red_color,green_color,blue_color);

% end displayAncestryData
end
