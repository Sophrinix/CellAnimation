function output_args=displayAncestryData(input_args)
%Usage
%This module is used to overlay cell outlines (using different colors to indicate different cell
%generations) and cell labels on the original images after tracking and save the resulting image.
%
%Input Structure Members
%AncestryLayout – Matrix describing the order of the columns in the tracks matrix.
%CellsAncestry – Matrix containing the ancestry records for the cells in the image.
%CellsLabel – The label matrix containing the cell outlines for the current image.
%ColorMap – Color map to be used in drawing the cell outlines for each generation. Each
%generation will use the next color in the color map until all colors have been used. Afterwards,
%the colors in the map are recycled.
%
%CurFrame – Integer containing the current frame number.
%CurrentTracks – The list of the tracks for the current image.
%DS – The directory separator to be used when generating file names (“\” for Windows, “/” for
%Unix/Linux).
%Image – The original image which will be used to generate the image with overlayed outlines
%and labels.
%ImageFileName – The root of the image file name to be used when generating the image file
%name for the current image in combination with the current frame number.
%NumberFormat – A string indicating the number format of the file name to be used when saving
%the overlayed image.
%ProlDir – Output directory where the resulting image will be saved.
%TracksLayout – Matrix describing the order of the columns in the tracks matrix.
%
%Output Structure Members
%None.
%
%Example
%
%display_ancestry_function.InstanceName='DisplayAncestry';
%display_ancestry_function.FunctionHandle=@displayAncestryData;
%display_ancestry_function.FunctionArgs.Image.FunctionInstance='ReadImagesInOv
%erlayLoop';
%display_ancestry_function.FunctionArgs.Image.OutputArg='Image';
%display_ancestry_function.FunctionArgs.CurrentTracks.FunctionInstance='GetCur
%rentTracks2';
%display_ancestry_function.FunctionArgs.CurrentTracks.OutputArg='Tracks';
%display_ancestry_function.FunctionArgs.CellsLabel.FunctionInstance='LoadCells
%Label';
%display_ancestry_function.FunctionArgs.CellsLabel.OutputArg='cells_lbl';
%display_ancestry_function.FunctionArgs.CellsAncestry.FunctionInstance='ImageO
%verlayLoop';
%display_ancestry_function.FunctionArgs.CellsAncestry.InputArg='CellsAncestry'
%;
%display_ancestry_function.FunctionArgs.CurFrame.FunctionInstance='ImageOverla
%yLoop';
%display_ancestry_function.FunctionArgs.CurFrame.OutputArg='LoopCounter';
%display_ancestry_function.FunctionArgs.ColorMap.FunctionInstance='LoadColorma
%p';
%display_ancestry_function.FunctionArgs.ColorMap.OutputArg='cmap';
%display_ancestry_function.FunctionArgs.NumberFormat.Value=TrackStruct.NumberF
%ormat;
%display_ancestry_function.FunctionArgs.TracksLayout.Value=tracks_layout;
%display_ancestry_function.FunctionArgs.ProlDir.Value=TrackStruct.ProlDir;
%display_ancestry_function.FunctionArgs.ImageFileName.Value=TrackStruct.ImageF
%ileName;
%display_ancestry_function.FunctionArgs.DS.Value=ds;
%display_ancestry_function.FunctionArgs.AncestryLayout.Value=ancestry_layout;
%image_overlay_loop_functions=addToFunctionChain(image_overlay_loop_functions,
%display_ancestry_function);

cur_img=input_args.Image.Value;
cur_tracks=input_args.CurrentTracks.Value;
cells_lbl=input_args.CellsLabel.Value;
cells_ancestry=input_args.CellsAncestry.Value;
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

prol_dir=input_args.ProlDir.Value;
img_file_name=input_args.ImageFileName.Value;
ds=input_args.DS.Value;
output1=[prol_dir ds img_file_name];

tracks_layout=input_args.TracksLayout.Value;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

ancestry_layout=input_args.AncestryLayout.Value;
ancestryIDCol=ancestry_layout.TrackIDCol;
generationCol=ancestry_layout.GenerationCol;

cur_cell_number=size(cur_tracks,1);
cell_lbl_id=zeros(cur_cell_number,1);
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
    %write the text in blue
    red_color(text_coord_lin)=max_pxl;
    green_color(text_coord_lin)=max_pxl;
    blue_color(text_coord_lin)=max_pxl;
    
%     plot(cell_bounds{1}(:,2),cell_bounds{1}(:,1),'Color',cmap(cell_generation,:),'LineWidth',1)
%     text(cur_centroid(2),cur_centroid(1),num2str(cell_id),'Color','g','HorizontalAlignment','center',...
%         'FontSize',5);    
end
% toc
% hold off
% drawnow;
%write the combined channels as an rgb image
imwrite(cat(3,red_color,green_color,blue_color),[output1 num2str(curframe,number_fmt) '.jpg'],'jpg');
% saveas(h1,[output1 num2str(curframe,'%03d') '.jpg'],'jpg');
output_args=[];

% end displayAncestryData
end
