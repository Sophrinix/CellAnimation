function []=cells_track(track_struct)

framecount=track_struct.FrameCount;
startframe=track_struct.StartFrame;
timeframe=track_struct.TimeFrame;
file_base=track_struct.ImageFileBase;
file_ext=track_struct.ImgExt;
img_channel=track_struct.Channel;
seg_file_root=track_struct.SegFileRoot;
frame_step=track_struct.FrameStep;
number_fmt=track_struct.NumberFormat;
min_blob_area=track_struct.MinCytoArea;
max_frames_missing=track_struct.MaxFramesMissing;
prev_cells_lbl=[];
max_pxl=intmax('uint16');
track_dir=track_struct.TrackDir;
img_file_name=track_struct.ImageFileName;
ds=track_struct.DS;
tracks_layout=track_struct.TracksLayout;
timeCol=tracks_layout.TimeCol;

for i=1:frame_step:frame_step*framecount
    curframe=startframe+i-1
    img_to_proc=imread([file_base num2str(curframe,number_fmt) file_ext]);
    img_sz=size(img_to_proc);
    switch img_channel
        case 'r'
            img_to_proc=img_to_proc(:,:,1);
        case 'g'
            img_to_proc=img_to_proc(:,:,2);
        case 'b'
            img_to_proc=img_to_proc(:,:,3);
    end    
    cells_lbl=segment_nuclei(img_to_proc,track_struct);    
    if isempty(prev_cells_lbl)
        [shape_params cells_centroids]=getShapeParams(cells_lbl);
        cur_time=repmat((curframe-1)*timeframe,size(cells_centroids,1),1);
        track_ids=[1:size(cells_centroids,1)]';
        tracks=[track_ids cur_time cells_centroids shape_params];        
    else
        %connect existing tracks to the cells in this frame, add new tracks
        %and potentially resegment cells_lbl based on track logic
        [tracks cells_lbl]=updateTracks(cells_lbl, tracks, curframe, min_blob_area, track_struct);
    end
    save([seg_file_root num2str(curframe,number_fmt)],'cells_lbl');
    
    %save cell outlines and ids for visual inspection
    cur_tracks=tracks(tracks(:,timeCol)==(curframe-1)*timeframe,:);
    displaydata(img_to_proc, cur_tracks, cells_lbl, img_sz, max_pxl, [track_dir ds img_file_name], ...
        curframe, number_fmt, tracks_layout);
    prev_cells_lbl=cells_lbl;
end

disp('Saving tracks...')
save(track_struct.TracksFile,'tracks');

end %end cells_track


function [meanDisplacement sdDisplacement]=getFrameMeanDisplacement(prev_frame_centroids, cur_frame_centroids)
%compute the delaunay triangulation
delaunay_tri=delaunay(prev_frame_centroids(:,1),prev_frame_centroids(:,2));
nearest_neighbors_idx=dsearch(prev_frame_centroids(:,1),prev_frame_centroids(:,2),delaunay_tri,...
    cur_frame_centroids(:,1),cur_frame_centroids(:,2));
cell_displacements=hypot(cur_frame_centroids(:,1)-prev_frame_centroids(nearest_neighbors_idx,1),...
    cur_frame_centroids(:,2)-prev_frame_centroids(nearest_neighbors_idx,2));
meanDisplacement=mean(cell_displacements);
sdDisplacement=std(cell_displacements);
end %end getFrameMeanDisplacement


function [tracks cells_lbl]=updateTracks(cells_lbl, tracks, curframe, min_blob_area, track_struct)
%connect existing tracks to the cells in this frame, add new tracks
%and potentially resegment cells_lbl based on track logic
[shape_params cells_centroids]=getShapeParams(cells_lbl);
centr_len=size(cells_centroids,1);
%assign temporary ids for the current centroids
tempIDs=[1:centr_len]';
tracks_layout=track_struct.TracksLayout;
timeCol=tracks_layout.TimeCol;
trackIDCol=tracks_layout.TrackIDCol;
timeframe=track_struct.TimeFrame;
max_frames_missing=track_struct.MaxFramesMissing;
%get the current tracks (up to the last frame)
cur_tracks=getCurrentTracks(tracks, curframe-1, timeframe, timeCol, trackIDCol, max_frames_missing);

%get the search radius - how far we'll look for cells to continue existing
%tracks
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
[meanDispl sdDispl]=getFrameMeanDisplacement(cur_tracks(:,centroid1Col:centroid2Col), cells_centroids);
search_radius=meanDispl+10*sdDispl;
%make the intial list of cells that are not assigned to tracks
unassignedIDs=tempIDs;
trackAssignments=[];
max_tracks=max(tracks(:,trackIDCol));
%while we still have cells that aren't assigned to any tracks loop
while(~isempty(unassignedIDs))    
    [unassignedIDs bSplit new_cells_lbl trackAssignments]=assignCellToTrackUsingDistAndAge(unassignedIDs,...
        cells_lbl,shape_params,cells_centroids,cur_tracks,search_radius,trackAssignments,...
        min_blob_area,track_struct,max_tracks,tracks);
    if (bSplit)
        cells_lbl=new_cells_lbl;
        [shape_params cells_centroids]=getShapeParams(cells_lbl);
    end
end

%all assignments are complete -complete the track assignments
%sort the track assignments using the tempIDs
[dummy tracks_sort_idx]=sort(trackAssignments(:,2));
tracks_ids_sorted=trackAssignments(tracks_sort_idx,1);
cur_time=(curframe-1)*timeframe;
tracks=[tracks; [tracks_ids_sorted repmat(cur_time,size(tracks_ids_sorted,1),1)] cells_centroids shape_params];

% end updateTracks
end

function [unassignedIDs bSplit new_cells_lbl trackAssignments]=assignCellToTrackUsingDist(unassignedIDs,...
    cells_lbl,shape_params,cells_centroids,cur_tracks,search_radius,trackAssignments...
    ,min_blob_area,track_struct, max_tracks)
%assign current cell to a track
curID=unassignedIDs(1);
%first get a list of all tracks in the current search radius
cur_cell_centroid=cells_centroids(curID,:);
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
dist_to_tracks=hypot(cur_tracks(:,centroid1Col)-cur_cell_centroid(1),...
    cur_tracks(:,centroid2Col)-cur_cell_centroid(2));
nearby_tracks_idx=(dist_to_tracks<search_radius);
%keep only tracks in the current search nhood
dist_to_tracks=dist_to_tracks(nearby_tracks_idx);
nearby_tracks=cur_tracks(nearby_tracks_idx,:);
if (isempty(nearby_tracks))
    nearby_tracks_ids=[];
else
    %sort tracks using distance parameter
    [dummy dist_to_tracks_sort_idx]=sort(dist_to_tracks);
    nearby_tracks_sorted=nearby_tracks(dist_to_tracks_sort_idx,:);
    nearby_tracks_ids=nearby_tracks_sorted(:,trackIDCol);    
    bFirstTimeInLooop=true;
end
%does list have at least one track?
while (~isempty(nearby_tracks_ids))
    if (bFirstTimeInLooop)
        %call split routine
        bFirstTimeInLooop=false;
        bSplit=false;
%         [bSplit new_cells_lbl newIDs]=splitCellUsingDist(curID,cells_lbl,shape_params,cells_centroids,...
%             nearby_tracks,min_blob_area,tracks_layout);
        if (bSplit)
            cells_props=regionprops(new_cells_lbl,'Centroid');            
            cells_centroids=[cells_props.Centroid]';
            centr_len=size(cells_centroids,1);
            cells_centroids=[cells_centroids(2:2:centr_len) cells_centroids(1:2:centr_len)];
            
            %remove the assignments for all the tracks in the nhood of
            %these new cells
            nearby_tracks_ids=[];
            splitIDs=[curID; newIDs];
            for i=1:size(splitIDs,1)                
                cur_cell_centroid=cells_centroids(splitIDs(i),:);
                dist_to_tracks=hypot(cur_tracks(:,centroid1Col)-cur_cell_centroid(1),...
                    cur_tracks(:,centroid2Col)-cur_cell_centroid(2));
                nearby_tracks_idx=(dist_to_tracks<search_radius);
                cur_nearby_tracks_ids=cur_tracks(nearby_tracks_idx,trackIDCol);
                nearby_tracks_ids=[nearby_tracks_ids; cur_tracks(nearby_tracks_idx,trackIDCol)];                
            end
            nearby_tracks_ids=unique(nearby_tracks_ids);
            %find the track assignments containing these track ids and
            %remove them. add the cells that used to be assigned to these tracks
            %back into the unassigned list
            if (~isempty(trackAssignments))
                assignments_to_be_removed_idx=ismember(trackAssignments(:,1),nearby_tracks_ids);
                %get the cell ids to be put back in the unassigned list
                cell_ids_to_be_unassigned=trackAssignments(assignments_to_be_removed_idx,2);                
                %put the cells back into the unassigned list and sort the list
                unassignedIDs=[unassignedIDs; newIDs; cell_ids_to_be_unassigned];
                %remove the track assigments
                trackAssignments(assignments_to_be_removed_idx,:)=[];
            else
                unassignedIDs=[unassignedIDs; newIDs];
            end
            unassignedIDs=sort(unassignedIDs);            
            return;
        end
    end    
    %pick the best track for current cell
    best_track_id=nearby_tracks_ids(trackIDCol);   
    
    %find out if the track is already claimed by another cell
    if (isempty(trackAssignments))
        track_idx=[];
    else
        track_idx=find(trackAssignments(:,1)==best_track_id,1);
    end        
    if (isempty(track_idx))
        %track is not claimed-assign it to this cell
        trackAssignments=[trackAssignments; [best_track_id curID]];
        %remove cell from unassigned list
        unassignedIDs(1)=[];
        %cell hasn't been split so no updated cells_lbl
        bSplit=false;
        new_cells_lbl=[];
        return;
    else
        track_centroid=nearby_tracks_sorted(1,centroid1Col:centroid2Col);
        assert(nearby_tracks_sorted(trackIDCol)==best_track_id);
        candidate_cell_centroids=[cur_cell_centroid; cells_centroids(trackAssignments(track_idx,2),:)];
        %rank cells according to which one is nearest to this track
        cell_scores=rankCellsUsingDist(track_centroid, candidate_cell_centroids);
        %another cell is claiming this track. is this claim stronger?
        if (cell_scores(1)>cell_scores(2))
            %this cell's claim to the track is stronger            
            %remove this cell from unassigned list and add the weaker cell
            unassignedIDs(1)=trackAssignments(track_idx,2);
            trackAssignments(track_idx,2)=curID;
            %cell hasn't been split so no updated cells_lbl
            bSplit=false;
            new_cells_lbl=[];
            return;
        else
            %this cell's claim to the track is weaker-remove the track from
            %the list
            nearby_tracks_ids(1)=[];
            nearby_tracks_sorted(1,:)=[];                        
        end
    end
end


%list of potential tracks is empty
%start new track
if isempty(trackAssignments)
    max_track_id=max([cur_tracks(:,trackIDCol);max_tracks]);
else
    max_track_id=max([cur_tracks(:,trackIDCol); trackAssignments(:,1); max_tracks]);
end
trackAssignments=[trackAssignments; [max_track_id+1 curID]];
%remove cell from unassigned list
unassignedIDs(1)=[];
%cell hasn't been split so no updated cells_lbl
bSplit=false;
new_cells_lbl=[];

%end assignCellToTrackUsingDist
end

function [bSplit new_cells_lbl new_label_ids]=splitCellUsingDist(curID,cells_lbl,shape_params,cells_centroids,...
    cur_tracks, min_blob_area, tracks_layout)
%is this cell really more than one cell that has been inappropriately
%segmented? evaluate using distance to existing tracks only
tracks_len=size(cur_tracks,1);
if (tracks_len<2)
    %less than two tracks are in the neighborhood of this cell therefore logic doesn't
    %indicate improper segmentation
    bSplit=false;
    new_cells_lbl=[];
    new_label_ids=[];
    return;
end
%two or more tracks are in the neighborhood of this cell. is this cell a
%best candidate for more than one track?
tracks_pointing_to_cell_idx=false(tracks_len,1);
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
areaCol=tracks_layout.AreaCol;
for i=1:tracks_len
    cur_track_centroid=cur_tracks(i,centroid1Col:centroid2Col);
    dist_to_cells=hypot(cells_centroids(:,1)-cur_track_centroid(1), cells_centroids(:,2)-cur_track_centroid(2));
    [dummy nearest_cell_idx]=min(dist_to_cells);
    if (nearest_cell_idx==curID)
        tracks_pointing_to_cell_idx(i)=true;
    end        
end
tracks_pointing_to_cell=cur_tracks(tracks_pointing_to_cell_idx,:);
tracks_len=size(tracks_pointing_to_cell,1);
if (tracks_len<2)
    %less than two tracks are pointing to this cell therefore logic doesn't
    %indicate improper segmentation
    bSplit=false;
    new_cells_lbl=[];
    new_label_ids=[];
    return;
end

%found at least two tracks that want this cell to continue them. we'll
%check for improper segmentation using area
tracks_area_sum=sum(tracks_pointing_to_cell(:,areaCol));
%assuming shape params start after second centroid col
cur_cell_area=shape_params(curID,areaCol-centroid2Col);
%have two or more cells been merged by the segmentation?
if (cur_cell_area<0.75*tracks_area_sum)
    %cells haven't been merged no improper segmentation
    bSplit=false;
    new_cells_lbl=[];
    new_label_ids=[];
    return;
end
%cell is really the result of an improper segmentation of two or more cells
%split the cell in cells_lbl
bSplit=true;
cur_blob=cells_lbl==curID;
[blob_idx_1 blob_idx_2]=find(cur_blob);
segmentation_idx=clusterdata([blob_idx_1 blob_idx_2], 'maxclust', tracks_len, 'linkage', 'average');
%get the areas of the newly segmented blobs
new_blob_areas=accumarray(segmentation_idx, 1);
%blobs smaller than our min threshold have to be unsegmented by assigning
%them to the nearest blob that is larger than minimum blob area
segmentation_ids=[1:length(new_blob_areas)];
valid_new_blobs_idx=(new_blob_areas>min_blob_area);
valid_areas=new_blob_areas(valid_new_blobs_idx);
valid_segmentation_ids=segmentation_ids(valid_new_blobs_idx);
if isempty(valid_segmentation_ids)
    %the resulting split cells will be to small
    bSplit=false;
    new_cells_lbl=[];
    new_label_ids=[];
    return;
end
valid_len=length(valid_segmentation_ids);
if (valid_len==1)
    %only one of the blobs will be large enough so we can't split
    bSplit=false;
    new_cells_lbl=[];
    new_label_ids=[];
    return;
end
invalid_segmentation_ids=segmentation_ids(~valid_new_blobs_idx);
if (~isempty(invalid_segmentation_ids))
    invalid_areas=new_blob_areas(~valid_new_blobs_idx);
    %calculate the centroids of the new valid blobs    
    valid_centroids=zeros(valid_len,2);
    for i=1:valid_len
        cur_segmentation_id=valid_segmentation_ids(i);
        cur_area=valid_areas(i);
        cur_segmentation_idx=segmentation_idx==cur_segmentation_id;
        segmented_idx_1=blob_idx_1(cur_segmentation_idx);
        segmented_idx_2=blob_idx_2(cur_segmentation_idx);
        valid_centroids(i,:)=[sum(segmented_idx_1./cur_area) sum(segmented_idx_2./cur_area)];
    end
    invalid_len=length(invalid_segmentation_ids);    
    %calculate the centroids of the new invalid blobs
    %reassign the invalid segmentations to their nearest valid neighbors
    for i=1:invalid_len
        cur_segmentation_id=invalid_segmentation_ids(i);
        cur_area=invalid_areas(i);
        cur_segmentation_idx=segmentation_idx==cur_segmentation_id;
        segmented_idx_1=blob_idx_1(cur_segmentation_idx);
        segmented_idx_2=blob_idx_2(cur_segmentation_idx);
        cur_centroid=[sum(segmented_idx_1./cur_area) sum(segmented_idx_2./cur_area)];
        dist_to_valid_centroids=hypot(valid_centroids(:,1)-cur_centroid(1),...
            valid_centroids(:,2)-cur_centroid(2));
        [dummy closest_valid_centroid_idx]=min(dist_to_valid_centroids);
        nearest_valid_id=valid_segmentation_ids(closest_valid_centroid_idx);
        segmentation_idx(segmentation_idx==cur_segmentation_id)=nearest_valid_id;
    end
end
    
    
max_lbl=max(cells_lbl(:));
new_label_ids=[(max_lbl+1):(max_lbl+valid_len-1)]';

splitIDs=[curID; new_label_ids];
blob_lin_idx=sub2ind(size(cells_lbl),blob_idx_1,blob_idx_2);
new_cells_lbl=cells_lbl;
%need to have an id vector the length of the original  segmentation_ids
%segmentation_idx might have values 1 and 3 resulting in a splitID of
%length 2 which cannot be addresed with the index value 3
temp_ids=zeros(length(segmentation_ids),1);
temp_ids(ismember(segmentation_ids,valid_segmentation_ids))=splitIDs;
new_cells_lbl(blob_lin_idx)=temp_ids(segmentation_idx);

%end splitCell
end

function [unassignedIDs bSplit new_cells_lbl trackAssignments]=assignCellToTrackUsingDistAndAge(unassignedIDs,...
    cells_lbl,shape_params,cells_centroids,cur_tracks,search_radius,trackAssignments...
    ,min_blob_area,track_struct, max_tracks, tracks)
%assign current cell to a track
curID=unassignedIDs(1);
%first get a list of all tracks in the current search radius
tracks_layout=track_struct.TracksLayout;
cur_cell_centroid=cells_centroids(curID,:);
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
timeCol=tracks_layout.TimeCol;
negligible_dist=track_struct.NegligibleDistance;
dist_to_tracks=hypot(cur_tracks(:,centroid1Col)-cur_cell_centroid(1),...
    cur_tracks(:,centroid2Col)-cur_cell_centroid(2));
nearby_tracks_idx=(dist_to_tracks<search_radius);
%keep only tracks in the current search nhood
dist_to_tracks=dist_to_tracks(nearby_tracks_idx);
nearby_tracks=cur_tracks(nearby_tracks_idx,:);
if (isempty(nearby_tracks))
    nearby_tracks_ids=[];
else
    %sort tracks using distance parameter
    [dist_sorted dist_to_tracks_sort_idx]=sort(dist_to_tracks);
    nearby_tracks_sorted=nearby_tracks(dist_to_tracks_sort_idx,:);
    %get tracks that are too close to be sorted accurately by distance
    sort_by_age_idx=dist_sorted<negligible_dist;
    tracks_to_sort_by_age=nearby_tracks_sorted(sort_by_age_idx,:);
    nr_tracks=size(tracks_to_sort_by_age,1);
    if (nr_tracks>1)
        tracks_start_times=zeros(nr_tracks,1);
        for i=1:nr_tracks
            cur_track_id=tracks_to_sort_by_age(i,trackIDCol);
            cur_track_times=tracks(tracks(:,trackIDCol)==cur_track_id,timeCol);
            tracks_start_times(i)=cur_track_times(1);
        end
        [dummy age_sort_idx]=sort(tracks_start_times);
        %sort the tracks that are very close by age
        nearby_tracks_sorted(sort_by_age_idx,:)=tracks_to_sort_by_age(age_sort_idx,:);
    end
    nearby_tracks_ids=nearby_tracks_sorted(:,trackIDCol);    
    bFirstTimeInLooop=true;
end
%does list have at least one track?
while (~isempty(nearby_tracks_ids))
    if (bFirstTimeInLooop)
        %call split routine
        bFirstTimeInLooop=false;
        bSplit=false;
%         [bSplit new_cells_lbl newIDs]=splitCellUsingDist(curID,cells_lbl,shape_params,cells_centroids,...
%             nearby_tracks,min_blob_area,tracks_layout);
        if (bSplit)
            cells_props=regionprops(new_cells_lbl,'Centroid');            
            cells_centroids=[cells_props.Centroid]';
            centr_len=size(cells_centroids,1);
            cells_centroids=[cells_centroids(2:2:centr_len) cells_centroids(1:2:centr_len)];
            
            %remove the assignments for all the tracks in the nhood of
            %these new cells
            nearby_tracks_ids=[];
            splitIDs=[curID; newIDs];
            for i=1:size(splitIDs,1)                
                cur_cell_centroid=cells_centroids(splitIDs(i),:);
                dist_to_tracks=hypot(cur_tracks(:,centroid1Col)-cur_cell_centroid(1),...
                    cur_tracks(:,centroid2Col)-cur_cell_centroid(2));
                nearby_tracks_idx=(dist_to_tracks<search_radius);
                cur_nearby_tracks_ids=cur_tracks(nearby_tracks_idx,trackIDCol);
                nearby_tracks_ids=[nearby_tracks_ids; cur_tracks(nearby_tracks_idx,trackIDCol)];                
            end
            nearby_tracks_ids=unique(nearby_tracks_ids);
            %find the track assignments containing these track ids and
            %remove them. add the cells that used to be assigned to these tracks
            %back into the unassigned list
            if (~isempty(trackAssignments))
                assignments_to_be_removed_idx=ismember(trackAssignments(:,1),nearby_tracks_ids);
                %get the cell ids to be put back in the unassigned list
                cell_ids_to_be_unassigned=trackAssignments(assignments_to_be_removed_idx,2);                
                %put the cells back into the unassigned list and sort the list
                unassignedIDs=[unassignedIDs; newIDs; cell_ids_to_be_unassigned];
                %remove the track assigments
                trackAssignments(assignments_to_be_removed_idx,:)=[];
            else
                unassignedIDs=[unassignedIDs; newIDs];
            end
            unassignedIDs=sort(unassignedIDs);            
            return;
        end
    end    
    %pick the best track for current cell
    best_track_id=nearby_tracks_ids(trackIDCol);   
    
    %find out if the track is already claimed by another cell
    if (isempty(trackAssignments))
        track_idx=[];
    else
        track_idx=find(trackAssignments(:,1)==best_track_id,1);
    end        
    if (isempty(track_idx))
        %track is not claimed-assign it to this cell
        trackAssignments=[trackAssignments; [best_track_id curID]];
        %remove cell from unassigned list
        unassignedIDs(1)=[];
        %cell hasn't been split so no updated cells_lbl
        bSplit=false;
        new_cells_lbl=[];
        return;
    else
        track_centroid=nearby_tracks_sorted(1,centroid1Col:centroid2Col);
        assert(nearby_tracks_sorted(trackIDCol)==best_track_id);
        candidate_cell_centroids=[cur_cell_centroid; cells_centroids(trackAssignments(track_idx,2),:)];
        %rank cells according to which one is nearest to this track
        cell_scores=rankCellsUsingDist(track_centroid, candidate_cell_centroids);
        %another cell is claiming this track. is this claim stronger?
        if (cell_scores(1)>cell_scores(2))
            %this cell's claim to the track is stronger            
            %remove this cell from unassigned list and add the weaker cell
            unassignedIDs(1)=trackAssignments(track_idx,2);
            trackAssignments(track_idx,2)=curID;
            %cell hasn't been split so no updated cells_lbl
            bSplit=false;
            new_cells_lbl=[];
            return;
        else
            %this cell's claim to the track is weaker-remove the track from
            %the list
            nearby_tracks_ids(1)=[];
            nearby_tracks_sorted(1,:)=[];                        
        end
    end
end


%list of potential tracks is empty
%start new track
if isempty(trackAssignments)
    max_track_id=max([cur_tracks(:,trackIDCol);max_tracks]);
else
    max_track_id=max([cur_tracks(:,trackIDCol); trackAssignments(:,1); max_tracks]);
end
trackAssignments=[trackAssignments; [max_track_id+1 curID]];
%remove cell from unassigned list
unassignedIDs(1)=[];
%cell hasn't been split so no updated cells_lbl
bSplit=false;
new_cells_lbl=[];

%end assignCellToTrackUsingDist
end

function []=displaydata(cur_img, cur_tracks, cells_lbl, img_sz, max_pxl, output1, curframe,...
    number_fmt, tracks_layout)
%display and save the cell boundaries, cell ids and cell generations

cur_img=imnorm(cur_img,'uint8');
red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;


cur_cell_number=size(cur_tracks,1);

%i need to get the outlines of each individual cell since more than one
%cell might be in a blob
avg_filt=fspecial('average',[3 3]);
lbl_avg=imfilter(cells_lbl,avg_filt,'replicate');
lbl_avg=double(lbl_avg).*double(cells_lbl>0);
img_bounds=abs(double(cells_lbl)-lbl_avg);
img_bounds=im2bw(img_bounds,graythresh(img_bounds));

cell_bounds_lin=find(img_bounds);
%draw the cell bounds in red
red_color(cell_bounds_lin)=max_pxl;
green_color(cell_bounds_lin)=0;
blue_color(cell_bounds_lin)=0;

centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

for j=1:cur_cell_number
    cur_centroid=cur_tracks(j,centroid1Col:centroid2Col);
    cell_id=cur_tracks(j,trackIDCol);
    
    %add the cell ids
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
    red_color(text_coord_lin)=max_pxl;
    green_color(text_coord_lin)=max_pxl;
    blue_color(text_coord_lin)=max_pxl;
    
%     plot(cell_bounds{1}(:,2),cell_bounds{1}(:,1),'Color',cmap(cell_generation,:),'LineWidth',1)
%     text(cur_centroid(2),cur_centroid(1),num2str(cell_id),'Color','g','HorizontalAlignment','center',...
%         'FontSize',5);    
end

%write the combined channels as an rgb image
imwrite(cat(3,red_color,green_color,blue_color),[output1 num2str(curframe,number_fmt) '.jpg'],'jpg');

%end displaydata
end


function cell_scores=rankCellsUsingDist(cur_cell_centroid, candidate_cell_centroids)
%rank which cell is a better candidate for cur_cell_centroid using distance
%use a 0 (worst) to 1 (best) scale
dist_to_tracks=hypot(candidate_cell_centroids(:,1)-cur_cell_centroid(1),...
    candidate_cell_centroids(:,2)-cur_cell_centroid(2));
[dummy dist_rank]=sort(dist_to_tracks);
cell_scores=1.0./double(dist_rank);
%end rankCellsUsingDist
end

function cur_tracks=getCurrentTracks(tracks, curframe, timeframe, timeCol, trackIDCol, max_missing_frames)
cur_tracks=tracks(tracks(:,timeCol)==(curframe-1)*timeframe,:);
track_ids=cur_tracks(:,trackIDCol);
for i=1:max_missing_frames
    cur_time=(curframe-1-i)*timeframe;
    if (cur_time<0)
        break;
    end
    new_tracks_idx=tracks(:,timeCol)==cur_time;
    new_track_ids=tracks(new_tracks_idx,trackIDCol);
    [diff_track_ids diff_track_idx]=setdiff(new_track_ids,track_ids);
    if isempty(diff_track_ids)
        continue;
    end
    new_tracks=tracks(new_tracks_idx,:);
    diff_tracks=new_tracks(diff_track_idx,:);
    cur_tracks=[cur_tracks; diff_tracks];
    track_ids=[track_ids; diff_track_ids];
end

%end getCurrentTracks
end