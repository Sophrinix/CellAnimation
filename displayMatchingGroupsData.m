function output_args=displayMatchingGroupsData(input_args)

cur_img=input_args.Image.Value;
cur_tracks=input_args.CurrentTracks.Value;
cells_lbl=input_args.CellsLabel.Value;
group_ids=input_args.GroupIDs.Value;
curframe=input_args.CurFrame.Value;
cmap=input_args.ColorMap.Value;
number_fmt=input_args.NumberFormat.Value;

img_sz=size(cur_img);
max_pxl=intmax('uint8');
imnorm_args.IntegerClass.Value='uint8';
imnorm_args.RawImage.Value=cur_img;
imnorm_output=imNorm(imnorm_args);
cur_img=imnorm_output.Image;
red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

group_dir=input_args.MatchingGroupsDir.Value;
img_file_name=input_args.ImageFileName.Value;
ds=input_args.DS.Value;
output1=[group_dir ds img_file_name];

tracks_layout=input_args.TracksLayout.Value;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
groupIDCol=tracks_layout.MatchGroupIDCol;
b_print_group_id=input_args.PrintGroupID.Value;

%remove tracks that do not belong to the matching groups we want to
%display
tracks_we_want_idx=ismember(cur_tracks(:,groupIDCol),group_ids);
cur_tracks=cur_tracks(tracks_we_want_idx,:);

cur_cell_number=size(cur_tracks,1);

if (cur_cell_number>0)
    %i need to get the outlines of each individual cell since more than one
    %cell might be in a blob
    avg_filt=fspecial('average',[3 3]);
    lbl_avg=imfilter(cells_lbl,avg_filt,'replicate');
    lbl_avg=double(lbl_avg).*double(cells_lbl>0);
    img_bounds=abs(double(cells_lbl)-lbl_avg);
    img_bounds=img_bounds>0.1;
    bounds_lbl=zeros(img_sz);
    bounds_lbl(img_bounds)=cells_lbl(img_bounds);


    for j=1:cur_cell_number
        %draw the cell boundaries - different colors for different group ids
        cur_centroid=cur_tracks(j,centroid1Col:centroid2Col);
        cell_lbl_id=getLabelId(cells_lbl,cur_centroid);
        group_id=cur_tracks(j,groupIDCol);
        group_idx=find(group_ids==group_id);
        cell_bounds_idx=(bounds_lbl==cell_lbl_id);
        red_color(cell_bounds_idx)=max_pxl*cmap(group_idx,1);
        green_color(cell_bounds_idx)=max_pxl*cmap(group_idx,2);
        blue_color(cell_bounds_idx)=max_pxl*cmap(group_idx,3);
        cell_id=cur_tracks(j,trackIDCol);
        %draw the track ids
        if (b_print_group_id)
            text_img=text2im(num2str(group_id));
        else
            text_img=text2im(num2str(cell_id));
        end
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
        %write the text in blue
        red_color(text_coord_lin)=max_pxl;
        green_color(text_coord_lin)=max_pxl;
        blue_color(text_coord_lin)=max_pxl;
    end
end

imwrite(cat(3,red_color,green_color,blue_color),[output1 num2str(curframe,number_fmt) '.jpg'],'jpg');
output_args=[];

% end displayMatchingGroupsData
end