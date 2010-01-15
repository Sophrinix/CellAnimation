function []=validate_tracks(track_struct)
%track id column should be 1

file_struct=load(track_struct.TracksFile);
tracks=file_struct.tracks;
clear('file_struct');
file_struct=load('colormap_lines');
cmap=file_struct.cmap;
clear('file_struct');
%remove the color black from colormap
% cmap=cmap(sum(cmap,2)>0,:);
img_sz=[];

framecount=track_struct.FrameCount;
startframe=track_struct.StartFrame;
timeframe=track_struct.TimeFrame;
input1=track_struct.SegFileRoot;
frame_step=track_struct.FrameStep;
number_fmt=track_struct.NumberFormat;
max_merge_dist=track_struct.MaxMergeDist;
max_split_dist=track_struct.MaxSplitDist;
max_split_area=track_struct.MaxSplitArea;
min_split_ecc=track_struct.MinSplitEcc;
%layout of the tracks matrix
tracks_layout=track_struct.TracksLayout;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
timeCol=tracks_layout.TimeCol;
areaCol=tracks_layout.AreaCol;
eccCol=tracks_layout.EccCol;
%sort tracks by the time column
[dummy sort_idx]=sort(tracks(:,timeCol));
tracks=tracks(sort_idx,:);
%get the list of unique tracks
track_ids=unique(tracks(:,trackIDCol));
untested_ids=track_ids;
tracks_to_be_merged=[];

%first merge any tracks that may have been improperly split
while (~isempty(untested_ids))
    curID=untested_ids(1);
    cur_track_idx=(tracks(:,trackIDCol)==curID);
    cur_track=tracks(cur_track_idx,:);
    cur_track_times=cur_track(:,timeCol);
    track_start_time=cur_track_times(1);
    %get the tracks that exist when this track appears for now just tracks
    %in the current time for the future we might add other times
    existing_tracks_idx=(tracks(:,timeCol)==track_start_time)&(~cur_track_idx);
    existing_tracks=tracks(existing_tracks_idx,:);
    cur_track_centroid=cur_track(1,centroid1Col:centroid2Col);
    existing_tracks_centroids=existing_tracks(:,centroid1Col:centroid2Col);
    %get the tracks that are near our cell    
    dist_to_existing_tracks=hypot(existing_tracks_centroids(:,1)-cur_track_centroid(1),...
        existing_tracks_centroids(:,2)-cur_track_centroid(2));    
    merge_candidates_idx=dist_to_existing_tracks<max_merge_dist;
    merge_candidates=existing_tracks(merge_candidates_idx,:);
    if isempty(merge_candidates)
        %no possible candidates to merge with so move on to next track
        untested_ids(1)=[];
        continue;
    end
    dist_to_existing_tracks=dist_to_existing_tracks(merge_candidates_idx);
    %sort the merge candidates by distance
    [dummy sort_idx]=sort(dist_to_existing_tracks);
    merge_candidates=merge_candidates(sort_idx,trackIDCol);
    
    %we have some tracks that may need to be merged with this track
    candidates_nr=size(merge_candidates,1);
    for j=1:candidates_nr
        candidateID=merge_candidates(j);
        candidate_track=tracks(tracks(:,trackIDCol)==candidateID,:);
        %get the times at which track exists
        candidate_times=candidate_track(:,timeCol);
        %get the times when both tracks exist
        [dummy cur_track_common_idx candidate_track_common_idx]=intersect(cur_track_times,candidate_times);
        %get the centroids at those times
        cur_track_common_times_centroids=cur_track(cur_track_common_idx,centroid1Col:centroid2Col);
        candidate_common_times_centroids=candidate_track(candidate_track_common_idx,centroid1Col:centroid2Col);
        dist_between_tracks=hypot(candidate_common_times_centroids(:,1)-cur_track_common_times_centroids(:,1),...
            candidate_common_times_centroids(:,2)-cur_track_common_times_centroids(:,2));
        if (max(dist_between_tracks)<max_merge_dist)
            %found a track we should merge with
            tracks_to_be_merged=[tracks_to_be_merged; [candidateID curID]];
            %remove the candidateID from the list of tracks to be checked
            untested_ids(untested_ids==candidateID)=[];
            break;
        end        
    end
    untested_ids(1)=[];   
end

if (~isempty(tracks_to_be_merged))
    %perform the actual merge
    tracks=mergeTracks(tracks, track_struct, tracks_to_be_merged);
end

track_ids=unique(tracks(:,trackIDCol));
%this works if tracks are sorted by time
[track_ids tracks_first_idx]=unique(tracks(:,trackIDCol),'first');
track_start_times=tracks(tracks_first_idx,timeCol);
untested_ids=track_ids;
tracks_to_be_merged=[];
nr_tracks=size(track_ids,1)-1;
blobIDCol=tracks_layout.BlobIDCol;
%also merge tracks that share the same blob_id
for i=1:nr_tracks
    curID=untested_ids(i);
    cur_track_idx=(tracks(:,trackIDCol)==curID);
    cur_track=tracks(cur_track_idx,:);
    cur_track_times=cur_track(:,timeCol);
    cur_track_blob_ids=cur_track(:,blobIDCol);
    track_start_time=cur_track_times(1);
    track_end_time=cur_track_times(end);
    %get only the tracks that appear at the same time with our current
    %track
    candidate_tracks_idx=ismember(tracks(:,timeCol),cur_track_times);
    %remove our cell from the list
    candidate_tracks_idx=candidate_tracks_idx&(~cur_track_idx);
    %get a list of all the track ids that exist when this track exists
    candidate_tracks=tracks(candidate_tracks_idx,:);
    %only should be primary to tracks that are younger than or at most same
    %age as the present track    
    tracks_older_than_current=track_ids(track_start_times<track_start_time);
    if (~isempty(tracks_older_than_current))
        exclude_candidates_idx=ismember(candidate_tracks(:,trackIDCol),tracks_older_than_current);
        candidate_tracks(exclude_candidates_idx,:)=[];
    end
    candidate_track_ids=unique(candidate_tracks(:,trackIDCol));    
    
    for j=1:size(cur_track,1)        
        if (isempty(candidate_track_ids))
            break;
        end
        cur_time=cur_track_times(j);
        curBlobID=cur_track_blob_ids(j);
        %get the tracks at this frame
        cur_tracks_idx=candidate_tracks(:,timeCol)==cur_time;
        cur_tracks=candidate_tracks(cur_tracks_idx,:);
        if (~isempty(cur_tracks))
            tracks_with_different_blob_ids_idx=~(cur_tracks(:,blobIDCol)==curBlobID);
            tracks_with_different_blob_ids=cur_tracks(tracks_with_different_blob_ids_idx, trackIDCol);
            %exclude the tracks with different blob ids from the list of
            %possible merge candidates
            exclude_tracks_idx=ismember(candidate_tracks(:,trackIDCol),tracks_with_different_blob_ids);
            candidate_tracks(exclude_tracks_idx,:)=[];
            candidate_track_ids=unique(candidate_tracks(:,trackIDCol));
        end
    end
    %get any preexisting merge records for the current ID
    if (~isempty(tracks_to_be_merged))
        ids_already_recorded_idx=tracks_to_be_merged(:,2)==curID;
        ids_already_recorded=tracks_to_be_merged(ids_already_recorded_idx,1);
        if (~isempty(ids_already_recorded))
            exclude_ids_idx=ismember(candidate_track_ids,ids_already_recorded);
            candidate_track_ids(exclude_ids_idx)=[];
        end
    end
    if (~isempty(candidate_track_ids))        
        tracks_to_be_merged=[tracks_to_be_merged; repmat(curID,size(candidate_track_ids,1),1) candidate_track_ids];
    end
end

if (~isempty(tracks_to_be_merged))
    %perform the actual merge
    tracks=mergeTracks(tracks, track_struct, tracks_to_be_merged);
end


%detect any mitotic events
track_ids=unique(tracks(:,trackIDCol));
%we'll remove track ids that are present in the first frame since we can't
%tell if the cells in the frame are the result of a split
first_frame_ids=tracks(tracks(:,timeCol)==0,trackIDCol);
first_frame_ids_len=length(first_frame_ids);
stop_times=zeros(first_frame_ids_len,1);
for i=1:first_frame_ids_len
    track_times=tracks(tracks(:,trackIDCol)==first_frame_ids(i),timeCol);
    stop_times(i)=track_times(end);
end
cells_ancestry=[first_frame_ids zeros(first_frame_ids_len,1) ones(first_frame_ids_len,1)...
    zeros(first_frame_ids_len,1) stop_times];
untested_ids=setdiff(track_ids,first_frame_ids);
split_cells=[];

while (~isempty(untested_ids))
    curID=untested_ids(1);
    cur_track_idx=(tracks(:,trackIDCol)==curID);
    cur_track=tracks(cur_track_idx,:);
    cur_track_median_area=median(cur_track(:,areaCol));    
    cur_track_times=cur_track(:,timeCol);
    track_start_time=cur_track_times(1);
    track_end_time=cur_track_times(end);
    cur_area=cur_track(1,areaCol);
    if (cur_area>1.3*cur_track_median_area)
        %a cell is smaller right after splitting
        untested_ids(1)=[];
        continue;
    end
    if (cur_area>max_split_area)
        %a cell is smaller right after splitting
        untested_ids(1)=[];
        continue;
    end
%     cur_ecc=cur_track(1,eccCol);
%     if (cur_ecc<min_split_ecc)
%         %nuclei are elongated right after splitting
%         untested_ids(1)=[];
%         continue;
%     end
    %get the tracks that exist when this track appears for now just tracks
    %in the current time for the future we might add other times
    existing_tracks_idx=(tracks(:,timeCol)==track_start_time)&(~cur_track_idx);
    existing_tracks=tracks(existing_tracks_idx,:);
    cur_track_centroid=cur_track(1,centroid1Col:centroid2Col);
    existing_tracks_centroids=existing_tracks(:,centroid1Col:centroid2Col);
    %get the tracks that are near our cell    
    dist_to_existing_tracks=hypot(existing_tracks_centroids(:,1)-cur_track_centroid(1),...
        existing_tracks_centroids(:,2)-cur_track_centroid(2));    
    split_candidates_idx=dist_to_existing_tracks<max_split_dist;
    split_candidates=existing_tracks(split_candidates_idx,:);
    if isempty(split_candidates)
        %no possible candidates to merge with so move on to next track
        untested_ids(1)=[];
        continue;
    end    
    %sort the merge candidates by area    
    [dummy sort_idx]=sort(split_candidates(:,areaCol));
    split_candidates=split_candidates(sort_idx,trackIDCol);    
    
    %we have some tracks that may need to be merged with this track
    candidates_nr=size(split_candidates,1);
    for j=1:candidates_nr
        candidateID=split_candidates(j);
        candidate_track=tracks(tracks(:,trackIDCol)==candidateID,:);
        candidate_start_time=candidate_track(1,timeCol);
        if (candidate_start_time>=track_start_time)
            %this track cannot be a parent of our track
            continue;
        end
        %get the times at which track exists
%         candidate_times=candidate_track(:,timeCol);
%         %get the times when both tracks exist
%         [common_times cur_track_common_idx candidate_track_common_idx]=intersect(cur_track_times,candidate_times);
%         if (length(common_times)<4)
%             continue;
%         end
        %get the centroids at those times
%         cur_track_common_times_centroids=cur_track(cur_track_common_idx,centroid1Col:centroid2Col);
%         candidate_common_times_centroids=candidate_track(candidate_track_common_idx,centroid1Col:centroid2Col);
%         %get the distance between tracks
%         dist_between_tracks=hypot(candidate_common_times_centroids(:,1)-cur_track_common_times_centroids(:,1),...
%             candidate_common_times_centroids(:,2)-cur_track_common_times_centroids(:,2));
        candidate_track_median_area=median(candidate_track(:,areaCol));
        potential_split_idx=candidate_track(:,timeCol)==track_start_time;
        potential_split_params=candidate_track(potential_split_idx,:);
        cur_area=potential_split_params(1,areaCol);
        if (cur_area>1.1*candidate_track_median_area)
            %a cell is smaller right after splitting            
            continue;
        end
        if (cur_area>max_split_area)
            %a cell is smaller right after splitting            
            continue;
        end
%         cur_ecc=potential_split_params(1,eccCol);
%         if (cur_ecc<min_split_ecc)
%             %nuclei are elongated right after splitting            
%             continue;
%         end
        split_cells=[split_cells; [candidateID curID track_start_time track_end_time]];
        break;
    end
    untested_ids(1)=[];   
end

%add an ancestry record for cells that are not in frame 1 and are not the
%result of a split
if (isempty(split_cells))
    cells_entering_frame_ids=setdiff(track_ids,first_frame_ids);
else
    cells_entering_frame_ids=setdiff(track_ids,[first_frame_ids; split_cells(:,2)]);
end
cells_entering_frame_len=length(cells_entering_frame_ids);
start_times=zeros(cells_entering_frame_len,1);
stop_times=zeros(cells_entering_frame_len,1);
for i=1:cells_entering_frame_len
    track_times=tracks(tracks(:,trackIDCol)==cells_entering_frame_ids(i),timeCol);
    start_times(i)=track_times(1);
    stop_times(i)=track_times(end);
end
cells_ancestry=[cells_ancestry; [cells_entering_frame_ids zeros(cells_entering_frame_len,1)... 
    ones(cells_entering_frame_len,1) start_times stop_times]];

if (~isempty(split_cells))
    [tracks cells_ancestry]=splitTracks(split_cells,tracks,cells_ancestry,track_struct);
end

disp('Saving matrices...')
output2=track_struct.ProlDir;
ds=track_struct.DS;
save([output2 ds 'tracks.mat'],'tracks');
save([output2 ds 'ancestry.mat'],'cells_ancestry');

disp('Saving images...')

%hide the image to speed up the displaydata
% h1=showmaxfigure(1);   
% set(h1,'Visible','off');
max_pxl=intmax('uint16');
fileext=track_struct.ImgExt;
filebase=track_struct.ImageFileBase;
img_channel=track_struct.Channel;


for i=1:frame_step:frame_step*framecount    
    curframe=startframe+i-1
    cur_time=(curframe-1)*timeframe;
    cur_tracks_idx=tracks(:,timeCol)==cur_time;
    cur_tracks=tracks(cur_tracks_idx,:);    
    cur_img=imread([filebase num2str(curframe,number_fmt) fileext]);
    %sometimes i only want one of the channels if the image is rgb
    switch img_channel
        case 'r'
            cur_img=cur_img(:,:,1);
        case 'g'
            cur_img=cur_img(:,:,2);
        case 'b'
            cur_img=cur_img(:,:,3);
    end          
            
    mat_filename=[input1 num2str(curframe,number_fmt) '.mat'];    
    file_struct=load(mat_filename);
    cells_lbl=file_struct.cells_lbl;
    clear('file_struct');    
    if (curframe==startframe)
        img_sz=size(cur_img);
    end
    
    displaydata(cur_img, cur_tracks, cells_lbl, cells_ancestry, curframe, cmap, img_sz, ...
        max_pxl, number_fmt, track_struct);
end

%sort tracks_with_stats by cell id
[dummy sort_idx]=sort(tracks(:,trackIDCol));
tracks=tracks(sort_idx,:);
column_names=...
    'Cell ID,Time,Centroid 1,Centroid 2,Area,Eccentricity,MajorAxisLength,MinorAxisLength,Orientation,Perimeter,Solidity';
disp('Saving 2D stats...')
xls_file=track_struct.ShapesXlsFile;
delete(xls_file);
dlmwrite(xls_file,column_names,'');
dlmwrite(xls_file,tracks,'-append');
column_names='Cells IDs,Parents IDs,Generations,Start Time,Split Time';
disp('Deleting spreadsheet if it exists...')
xls_file=track_struct.ProlXlsFile;
delete(xls_file);
disp('Saving ancestry data...')
dlmwrite(xls_file,column_names,'');
dlmwrite(xls_file,cells_ancestry,'-append');

%end validate_tracks
end

function tracks=mergeTracks(tracks, track_struct, tracks_to_be_merged)

framecount=track_struct.FrameCount;
startframe=track_struct.StartFrame;
timeframe=track_struct.TimeFrame;
seg_file_root=track_struct.SegFileRoot;
frame_step=track_struct.FrameStep;
number_fmt=track_struct.NumberFormat;
tracks_layout=track_struct.TracksLayout;
timeCol=tracks_layout.TimeCol;
trackIDCol=tracks_layout.TrackIDCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
areaCol=tracks_layout.AreaCol;
blobIDCol=tracks_layout.BlobIDCol;

%the primary ids will remain
primary_ids=tracks_to_be_merged(:,1);
%secondary ids will be gone after merging
secondary_ids=tracks_to_be_merged(:,2);

%replace those ids with their primaries in the primary list. this relies on
%the fact that those ids will be replaced by their primaries in the tracks
%list before we get to the ids that they are primary too. this is true if
%we detect tracks to be merged in chronological order. can't do it using
%ismember as a secondary can be a primary to another secondary. have to do
%it one-by-one in serial fashion
for i=1:length(primary_ids)
    cur_primary_id=primary_ids(i);
    %is this primary id secondary to some other primary id
    primary_to_this_primary_idx=find(secondary_ids==cur_primary_id,1);
    if (isempty(primary_to_this_primary_idx))
        continue;
    end
    %replace all records of this primary id in the primary_ids list
    primary_ids(primary_ids==cur_primary_id)=primary_ids(primary_to_this_primary_idx);
end

for i=1:frame_step:frame_step*framecount
    curframe=startframe+i-1
    cur_time=(curframe-1)*timeframe;
    cur_tracks_idx=tracks(:,timeCol)==cur_time;
    cur_tracks=tracks(cur_tracks_idx,:);    
    cur_ids=cur_tracks(:,trackIDCol);   
    primary_idx=ismember(primary_ids,cur_ids);
    cur_primary_ids=primary_ids(primary_idx);
    secondary_idx=ismember(secondary_ids,cur_ids);
    cur_secondary_ids=secondary_ids(secondary_idx);    
    bEmptySecondary=isempty(cur_secondary_ids);
    if (bEmptySecondary)
        %nothing to merge in this frame
        continue;
    end
    %something to merge or replace so load the cells_lbl    
    mat_filename=[seg_file_root num2str(curframe,number_fmt)];
    file_struct=load(mat_filename);
    cells_lbl=file_struct.cells_lbl;
    clear('file_struct');
    
    while (~isempty(cur_secondary_ids))
        secondary_id=cur_secondary_ids(1);
        %find a primary_id for this secondary_id
        primary_id_candidates=primary_ids(secondary_ids==secondary_id);
        for k=1:length(primary_id_candidates)
            primary_id=primary_id_candidates(k);
            primary_id_test=cur_primary_ids(cur_primary_ids==primary_id);
            if (~isempty(primary_id_test))
                break;
            end
        end
        if isempty(primary_id_test)
            %assign the properties of the secondary id to the primary id
            track_idx=(tracks(:,trackIDCol)==secondary_id&tracks(:,timeCol)==cur_time);
            tracks(track_idx,trackIDCol)=primary_id;
            %add the primary id to the list of current primary ids
            cur_primary_ids=[cur_primary_ids; primary_id];
        else            
            %combine the properties of the secondary id with the primary id
            %get both blobs
            %update the cur_tracks list since the tracks have been modified
            cur_tracks_idx=tracks(:,timeCol)==cur_time;
            cur_tracks=tracks(cur_tracks_idx,:);
            primary_idx=cur_tracks(:,trackIDCol)==primary_id;
            primary_centroid=cur_tracks(primary_idx,centroid1Col:centroid2Col);
            %the merged tracks will keep the blob id of the primary object
            primary_blob_id=cur_tracks(primary_idx,blobIDCol);
            primary_lbl_id=getLabelId(cells_lbl, primary_centroid);
            secondary_centroid=cur_tracks(cur_tracks(:,trackIDCol)==secondary_id,centroid1Col:centroid2Col);
            secondary_lbl_id=getLabelId(cells_lbl, secondary_centroid);
            cur_blobs=(cells_lbl==primary_lbl_id|cells_lbl==secondary_lbl_id);
            [cur_blobs_1 cur_blobs_2] =find(cur_blobs);
            %get the bounding box for the blobs
            max_1=max(cur_blobs_1);
            min_1=min(cur_blobs_1);
            max_2=max(cur_blobs_2);
            min_2=min(cur_blobs_2);
            % crop to the extent of the box so we run fast on a small
            % image
            cur_blobs=cur_blobs(min_1:max_1,min_2:max_2);
            cur_blobs_lbl=bwlabeln(cur_blobs);
            nr_blobs=max(cur_blobs_lbl(:));
            %determine if the two blobs are touching
            if (nr_blobs>1)
                %blobs are not touching - i need to connect them
                cur_blobs=connectBlobs(cur_blobs, nr_blobs);
                cur_blobs_lbl=bwlabeln(cur_blobs);
                %get the new coordinates
                [cur_blobs_1 cur_blobs_2]=find(cur_blobs);
                %update them to the main box
                cur_blobs_1=cur_blobs_1+min_1;
                cur_blobs_2=cur_blobs_2+min_2;

            end
            %calculate the new region props
            [new_shape_params new_centroid]=getShapeParams(cur_blobs_lbl);            
            %update the new centroids with respect to the uncropped image
            new_centroid=new_centroid+[min_1 min_2];
            %update the tracks matrix
            %remove the secondary id
            track_idx=(tracks(:,trackIDCol)==secondary_id&tracks(:,timeCol)==cur_time);
            tracks(track_idx,:)=[];            
            %update the primary id with the new params
            track_idx=(tracks(:,trackIDCol)==primary_id&tracks(:,timeCol)==cur_time);            
            tracks(track_idx,centroid1Col:centroid2Col)=new_centroid;
            %this assumes the shape params start with the area column
            assert(areaCol==5);
            tracks(track_idx,areaCol:end)=new_shape_params;
            tracks(track_idx,blobIDCol)=primary_blob_id;
            
            %update the cells_lbl
            blob_lin_idx=sub2ind(size(cells_lbl), cur_blobs_1, cur_blobs_2);
            cells_lbl(blob_lin_idx)=primary_lbl_id;          
        end
        cur_secondary_ids(cur_secondary_ids==secondary_id)=[]; 
    end
    %save the new cells_lbl
    save([seg_file_root num2str(curframe,number_fmt)],'cells_lbl');
end

%end mergeTracks
end

function [tracks cells_ancestry]=splitTracks(split_cells,tracks,cells_ancestry,track_struct)
%record cell ancestry for cells beyond the first frame
%sort the cells that split by the split time
tracks_layout=track_struct.TracksLayout;
trackIDCol=tracks_layout.TrackIDCol;
timeCol=tracks_layout.TimeCol;
max_track_id=max(tracks(:,trackIDCol));
ancestry_layout=track_struct.AncestryLayout;
stopTimeCol=ancestry_layout.StopTimeCol;
generationCol=ancestry_layout.GenerationCol;
ancestryIDCol=ancestry_layout.TrackIDCol;
time_frame=track_struct.TimeFrame;

if (~isempty(split_cells))
    [dummy sort_idx]=sort(split_cells(:,3));
    split_cells=split_cells(sort_idx,:);
    split_cells_len=size(split_cells,1);
else
    split_cells_len=0;
end


for i=1:split_cells_len
    %get the parent track id
    parent_track_id=split_cells(i,1);
    %get the split time
    split_time=split_cells(i,3);    
    %check if parent track has already been split
    parent_ancestry_idx=(cells_ancestry(:,ancestryIDCol)==parent_track_id);
    parent_track_stop_time=cells_ancestry(parent_ancestry_idx,stopTimeCol);
    parent_track_generation=cells_ancestry(parent_ancestry_idx,generationCol);
    if (parent_track_stop_time>=split_time)
        %parent track needs to be split        
        new_track_id=max_track_id+1;
        max_track_id=new_track_id;        
        %set the new end time for the parent track
        new_stop_time=split_time-time_frame;
        cells_ancestry(parent_ancestry_idx,stopTimeCol)=new_stop_time;
        %update the parent track id after the split with the new track id
        new_track_idx=(tracks(:,trackIDCol)==parent_track_id)&(tracks(:,timeCol)>new_stop_time);
        tracks(new_track_idx,trackIDCol)=new_track_id;                
        %create an ancestry record for the new track        
        cells_ancestry=[cells_ancestry; ...
            [new_track_id parent_track_id parent_track_generation+1 split_time parent_track_stop_time]];
    end
    %add an ancestry record for the other daughter cell resulting from the split
    daughter_id=split_cells(i,2);
    daughter_stop_time=split_cells(i,4);
    cells_ancestry=[cells_ancestry; ...
        [daughter_id parent_track_id parent_track_generation+1 split_time daughter_stop_time]];
end


%end splitTracks
end

function []=displaydata(cur_img, cur_tracks, cells_lbl, cells_ancestry, curframe, cmap,...
    img_sz, max_pxl, number_fmt, track_struct)
%display and save the cell boundaries, cell ids and cell generations
% imshow(cur_img,[])
% imagesc(cur_img);
% colormap(gray);
% axis image;
% axis off;
% hold on
% tic
%create a color version of our image so we can add cell
%boundaries and ids in color
cur_img=imnorm(cur_img,'uint8');
red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

prol_dir=track_struct.ProlDir;
img_file_name=track_struct.ImageFileName;
ds=track_struct.DS;
output1=[prol_dir ds img_file_name];

tracks_layout=track_struct.TracksLayout;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

ancestry_layout=track_struct.AncestryLayout;
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

% end function
end

function cell_areas=getCellAreas(cells_lbl, cur_tracks)
lbl_sz=size(cells_lbl);
cells_props=regionprops(cells_lbl,'Area');
lbl_areas=[cells_props.Area];
[cells_lbl_sub_1 cells_lbl_sub_2]=find(cells_lbl>0);
cells_lbl_ind=sub2ind(lbl_sz,cells_lbl_sub_1(1:10:end),cells_lbl_sub_2(1:10:end));
cells_lbl_val=cells_lbl(cells_lbl_ind);
%use knnclassify as the centroid might not be inside the cell
lbl_ids=knnclassify([cur_tracks(:,1) cur_tracks(:,2)]...
    ,[cells_lbl_sub_1(1:10:end) cells_lbl_sub_2(1:10:end)],cells_lbl_val);
%now the areas are synchronized to cur_tracks
cell_areas=lbl_areas(lbl_ids);
end

function connected_blob=connectBlobs(unconnected_blobs, nr_blobs)
%get a bunch of unconnected blobs and connect them using shortest distance
%lines

unconnected_blobs=imfill(unconnected_blobs,'holes');
%get the perimeter of the blobs
blobs_perim=bwperim(unconnected_blobs);
blobs_perim_lbl=bwlabeln(blobs_perim);
[connected_blob_1 connected_blob_2]=find(blobs_perim_lbl==1);
for i=2:nr_blobs
    [cur_blob_1 cur_blob_2]=find(blobs_perim_lbl==i);
    min_dist=Inf;
    for j=1:size(cur_blob_1,1)
        dist_to_cur_blob=hypot(connected_blob_1-cur_blob_1(j),connected_blob_2-cur_blob_2(j));
        [cur_min_dist cur_min_dist_idx]=min(dist_to_cur_blob);
        if (cur_min_dist<min_dist)
            min_dist=cur_min_dist;
            cur_blob_min_dist_idx=j;
            connected_blob_min_dist_idx=cur_min_dist_idx;
        end
    end
    
    connected_blob_closest_point_1=connected_blob_1(connected_blob_min_dist_idx);
    connected_blob_closest_point_2=connected_blob_2(connected_blob_min_dist_idx);
    cur_blob_closest_point_1=cur_blob_1(cur_blob_min_dist_idx);
    cur_blob_closest_point_2=cur_blob_2(cur_blob_min_dist_idx);
    
    cur_point=[connected_blob_closest_point_1 connected_blob_closest_point_2];
    min_dist=round(min_dist);
    connecting_line=zeros(min_dist,2);
    %progressively fill in the shortest path between the two
    %blobs
    for j=1:min_dist
        diff_1=cur_point(1)-cur_blob_closest_point_1;
        if (diff_1<0)
            cur_point(1)=cur_point(1)+1;
        elseif (diff_1>0)
            cur_point(1)=cur_point(1)-1;
        end
        diff_2=cur_point(2)-cur_blob_closest_point_2;
        if (diff_2<0)
            cur_point(2)=cur_point(2)+1;
        elseif (diff_2>0)
            cur_point(2)=cur_point(2)-1;
        end
        %add the cur_point to the list of pixels in the line connecting the
        %current blob to the connected blob
        connecting_line(j,:)=cur_point;                
    end
    
    %add the connecting line and the current blob to the connected blob
    connected_blob_1=[connected_blob_1; connecting_line(:,1); cur_blob_1];
    connected_blob_2=[connected_blob_2; connecting_line(:,2); cur_blob_2];
end

connected_blob_lin=sub2ind(size(unconnected_blobs),connected_blob_1,connected_blob_2);
connected_blob=unconnected_blobs;
connected_blob(connected_blob_lin)=true;

%end connectBlobs
end