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
prev_cells_lbl=[];
max_pxl=intmax('uint16');
track_dir=track_struct.TrackDir;
img_file_name=track_struct.ImageFileName;
ds=track_struct.DS;
tracks_layout=track_struct.TracksLayout;
timeCol=tracks_layout.TimeCol;
matching_groups=[];

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
        [tracks cells_lbl matching_groups]=updateTracks(cells_lbl, prev_cells_lbl, tracks, curframe, min_blob_area, track_struct, matching_groups);
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
save(track_struct.RankFile,'matching_groups');

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


function [tracks cells_lbl matching_groups]=updateTracks(cells_lbl, prev_cells_lbl, tracks, curframe, ...
    min_blob_area, track_struct, matching_groups)
%connect existing tracks to the cells in this frame, add new tracks
%and potentially resegment cells_lbl based on track logic
[shape_params cells_centroids]=getShapeParams(cells_lbl);
centr_len=size(cells_centroids,1);
%assign temporary ids for the current centroids
tempIDs=[1:centr_len]';
tracks_layout=track_struct.TracksLayout;
timeCol=tracks_layout.TimeCol;
trackIDCol=tracks_layout.TrackIDCol;
areaCol=tracks_layout.AreaCol;
solCol=tracks_layout.SolCol;
timeframe=track_struct.TimeFrame;
max_frames_missing=track_struct.MaxFramesMissing;
%get the current tracks (up to the last frame)
cur_tracks=getCurrentTracks(tracks, curframe-1, timeframe, timeCol, trackIDCol, max_frames_missing);
if (curframe>2)
    prev_tracks=getCurrentTracks(tracks,curframe-2, timeframe, timeCol, trackIDCol, max_frames_missing);
else
    prev_tracks=[];
end
%assuming solCol is last and areaCol is first of the 2D params. in addition
%there's a param for displacement
nr_params=solCol-areaCol+1;
params_means=mean(shape_params(:,1:nr_params));
params_sds=std(shape_params(:,1:nr_params));

%get the search radius - how far we'll look for cells to continue existing
%tracks
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
groupIDCol=tracks_layout.MatchGroupIDCol;
[meanDispl sdDispl]=getFrameMeanDisplacement(cur_tracks(:,centroid1Col:centroid2Col), cells_centroids);
search_radius=meanDispl+10*sdDispl;
params_coeff_var=params_sds./params_means; %coefficient of variation of the params;
%make the intial list of cells that are not assigned to tracks
unassignedIDs=tempIDs;
trackAssignments=[];
max_tracks=max(tracks(:,trackIDCol));
%while we still have cells that aren't assigned to any tracks loop
while(~isempty(unassignedIDs))
    cur_id=unassignedIDs(1);
    [unassignedIDs bSplit new_cells_lbl trackAssignments matching_groups group_idx]=assignCellToTrackUsingAll(unassignedIDs,...
        cells_lbl,prev_cells_lbl,shape_params,cells_centroids,cur_tracks,search_radius,trackAssignments,...
        track_struct,max_tracks,tracks,matching_groups,params_coeff_var,prev_tracks);
    if (bSplit)
        cells_lbl=new_cells_lbl;
        [shape_params cells_centroids]=getShapeParams(cells_lbl);
    else
        shape_params(cur_id,groupIDCol-areaCol+1)=group_idx;
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

function [unassignedIDs bSplit new_cells_lbl trackAssignments matching_groups group_idx]=assignCellToTrackUsingAll(unassignedIDs,...
    cells_lbl,prev_cells_lbl,shape_params,cells_centroids,cur_tracks,search_radius,trackAssignments...
    ,track_struct, max_tracks, tracks, matching_groups,params_coeff_var,prev_tracks)
%assign current cell to a track
cur_id=unassignedIDs(1);
%first get a list of all tracks in the current search radius
tracks_layout=track_struct.TracksLayout;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;

[nearby_tracks_sorted group_idx matching_groups]=getNearbyTracksSorted(cur_id, cells_centroids,shape_params,track_struct,cur_tracks...
    ,prev_tracks,search_radius,matching_groups,tracks,params_coeff_var);
nearby_tracks_ids=nearby_tracks_sorted(:,trackIDCol);
%does list have at least one track?
nearby_tracks_nr=length(nearby_tracks_ids);
for i=1:nearby_tracks_nr
    %pick the best track for current cell
    best_track_id=nearby_tracks_ids(i,trackIDCol);
    track_lbl_id=getLabelId(prev_cells_lbl, nearby_tracks_sorted(i,centroid1Col:centroid2Col));
    if (pathGoesThroughACell(cells_lbl, prev_cells_lbl,cur_id,track_lbl_id,0))
        %resulting path would go through another cell - this track cannot match this cell
        continue;
    end    
    if (isempty(trackAssignments))
        track_idx=[];
        competing_id=[];
    else
        track_idx=find(trackAssignments(:,1)==best_track_id,1);
        competing_id=trackAssignments(track_idx,2);
    end
    %is the track this cell wants claimed?
    if (isempty(track_idx))
        %track is not claimed-assign it to this cell
        trackAssignments=[trackAssignments; [best_track_id cur_id]];
        %remove cell from unassigned list
        unassignedIDs(1)=[];
        %cell hasn't been split so no updated cells_lbl
        bSplit=false;
        new_cells_lbl=[];
        return;
    else
        %which cell is prefered by the track?
        competing_shape_params=[shape_params(cur_id,:); shape_params(competing_id,:)];
        competing_cells_centroids=[cells_centroids(cur_id,:); cells_centroids(competing_id,:)];
        %sort the two cells with respect of their goodness-of-fit to the
        %track
        preferred_cell_id=getBetterMatchToTrack(nearby_tracks_sorted(i,:),competing_shape_params,competing_cells_centroids,...
            [cur_id;competing_id],prev_tracks,matching_groups,track_struct, cells_lbl, prev_cells_lbl);
        if (isempty(preferred_cell_id))
            continue;
        end
        if (preferred_cell_id==competing_id)
            %the competing cell is preferred does this cell have other
            %tracks it can get?
            if (canCellGetAnotherTrack(cur_id,nearby_tracks_sorted(i+1:nearby_tracks_nr,:),prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,true))            
               %it does. we'll have to leave this track to the
                %cell with the stronger claim
                continue;
            end
            %this cell has no other tracks it can connect to. does the
            %competing cell have other tracks it can get?
            other_tracks_sorted=getNearbyTracksSorted(competing_id, cells_centroids,shape_params,track_struct,cur_tracks,...
                prev_tracks,search_radius,matching_groups,tracks,params_coeff_var);
            %remove the current track
            other_tracks_sorted(other_tracks_sorted(:,trackIDCol)==nearby_tracks_sorted(i,trackIDCol),:)=[];
            if (~canCellGetAnotherTrack(competing_id,other_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false))            
               %this track is the last option for the competing cell
                %as well. we'll have to leave it to it since it is
                %preferred by the track
                continue;
            end
            %the competing cell has other options this cell doesn't so take
            %the track even though it has a weaker claim
            unassignedIDs(1)=competing_id;
            trackAssignments(track_idx,2)=cur_id;
            %cell hasn't been split so no updated cells_lbl
            bSplit=false;
            new_cells_lbl=[];
            return;
        else
            %this cell is preferred by the track
            if (~canCellGetAnotherTrack(cur_id,nearby_tracks_sorted(i+1:nearby_tracks_nr,:),prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false))            
               %this cell has no other tracks it can get
                %bump the cell with the weaker claim
                unassignedIDs(1)=trackAssignments(track_idx,2);
                trackAssignments(track_idx,2)=cur_id;
                %cell hasn't been split so no updated cells_lbl
                bSplit=false;
                new_cells_lbl=[];
                return;
            end
            %does the competing cell have other options?
            other_tracks_sorted=getNearbyTracksSorted(competing_id, cells_centroids,shape_params,track_struct,cur_tracks,...
                prev_tracks,search_radius,matching_groups,tracks,params_coeff_var);
            %remove the current track
            other_tracks_sorted(other_tracks_sorted(:,trackIDCol)==nearby_tracks_sorted(i,trackIDCol),:)=[];            
            if (canCellGetAnotherTrack(competing_id,other_tracks_sorted,prev_cells_lbl,cells_lbl,...
                    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,false))            
                %yes relinquish the track to this cell with the stronger
                %claim
                unassignedIDs(1)=trackAssignments(track_idx,2);
                trackAssignments(track_idx,2)=cur_id;
                %cell hasn't been split so no updated cells_lbl
                bSplit=false;
                new_cells_lbl=[];
                return;
            else
                %this cell can get other tracks, the competing cell
                %can't. let it keep the track even though it has a
                %weaker claim
                continue; 
            end            
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
trackAssignments=[trackAssignments; [max_track_id+1 cur_id]];
%remove cell from unassigned list
unassignedIDs(1)=[];
%cell hasn't been split so no updated cells_lbl
bSplit=false;
new_cells_lbl=[];

%end assignCellToTrackUsingAll
end

function track_ranks=rankParams(cur_shape_params,nearby_shape_params)
%rank how similar each previous nearby cell is to the current cell
[nr_tracks nr_params]=size(nearby_shape_params);
track_ranks=zeros(nr_tracks, nr_params);

for i=1:nr_params
    diff_from_cur_param=abs(cur_shape_params(:,i)-nearby_shape_params(:,i));
    [dummy param_rank]=sort(diff_from_cur_param);
    equal_vals_idx=~diff(diff_from_cur_param);
    replace_ranks_idx=[false; equal_vals_idx];
    replace_vals_idx=[equal_vals_idx; false];
    param_rank(replace_ranks_idx)=param_rank(replace_vals_idx);    
    track_ranks(:,i)=param_rank;
end
%end rankParams
end

function [ranking_order matching_groups group_idx]=addToMatchingGroups(matching_groups,cur_shape_params,nearby_params,...
    params_coeff_var,best_fit_idx,min_reliable_params, track_ranks, track_struct)
%we need to rank parameters by how near they are to their former values
%then once a ranking order is determined assign it to a matching_group. if
%none exists with the same ranking order create a new one. the first two
%parameters (distance and direction) are treated differently in that they
%are either first rank or last rank predictors.
best_fit_params=nearby_params(best_fit_idx,:);
matched_params=[cur_shape_params; best_fit_params];
%calculate the sd of the matched params and compare it with the sd of the
%nearby_params. parameters for which the sd of the matched params is
%greater than or equal to the sd of nearby_params are unreliable for
%ranking
sd_best_fit_params=std(matched_params(:,3:end));
min_params=min(matched_params);
max_params=max(matched_params);
pct_diff=1-min_params./max_params; %this way i only get values from 0-100%
smallest_pct_change=pct_diff(3:end)./params_coeff_var;
[dummy ranking_order]=sort(smallest_pct_change);
ranking_order=ranking_order+2;

if (size(nearby_params,1)==1)
    reliable_params_col=[1 2 3 4 5 6 7 8 9];
    ranking_order=[1 2 ranking_order];
else
    sd_nearby_params=std(nearby_params(:,3:end));
    reliable_params_col=find(sd_best_fit_params<sd_nearby_params)+2;
    %determine how reliable distance and direction are
    [dummy closest_distance_idx]=min(track_ranks(:,1));
    [dummy closest_angle_idx]=min(track_ranks(:,2));
    if (closest_angle_idx==closest_distance_idx)
        %both nearest distance and nearest angle point to the same cell
        %both distance and angle are reliable for this cell
        reliable_params_col=[1 2 reliable_params_col];
        ranking_order=[1 2 ranking_order];
    else
        %nearest distance and angle point to different cells
        %use the other parameters to pick which one is right
        angle_score=sum(track_ranks(closest_angle_idx,:));
        dist_score=sum(track_ranks(closest_distance_idx,:));
        if (abs(angle_score-dist_score)>2)
            %we have a clear favorite
            if (angle_score<dist_score)
                %direction is most significant
                reliable_params_col=[2 reliable_params_col];
                ranking_order=[2 ranking_order 1];
            else
                %distance is most significant
                reliable_params_col=[1 reliable_params_col 2];
                ranking_order=[1 ranking_order 2];
            end
        else
            angle_diffs_sorted=sort(nearby_params(:,2));
            distances_sorted=sort(nearby_params(:,1));
            dist_ratio=distances_sorted(1)/distances_sorted(2);
            max_angle_diff=track_struct.MaxAngleDiff;
            if ((angle_diffs_sorted(1)<max_angle_diff)&&(abs(angle_diffs_sorted(1)-angle_diffs_sorted(2))>max_angle_diff))
                %direction is most significant
                reliable_params_col=[2 reliable_params_col];
                ranking_order=[2 ranking_order 1];
            elseif ((distances_sorted(2)>track_struct.MinSecondDistance)&&(dist_ratio<track_struct.MaxDistRatio))
                %distance is most significant
                reliable_params_col=[1 reliable_params_col 2];
                ranking_order=[1 ranking_order 2];
            else
                %can't determine which is more reliable use both with
                %slight pref for distance
                reliable_params_col=[1 2 reliable_params_col];
                ranking_order=[1 2 ranking_order];
            end            
        end    
    end
end

reliable_params_idx=ismember(ranking_order,reliable_params_col);
%put the reliable params first
ranking_order=[ranking_order(reliable_params_idx) ranking_order(~reliable_params_idx)];
if (length(reliable_params_col)<min_reliable_params)
    %not enough reliable params to create a matching group
    group_idx=0;
    return;
end
nr_groups=size(matching_groups,1);
if (nr_groups==0)
    matching_groups=ranking_order;
    group_idx=1;
    return;
end
ranking_diff=matching_groups-repmat(ranking_order,nr_groups,1);
ranking_fit=sum(abs(ranking_diff),2);
group_idx=find(ranking_fit==0);
if (isempty(group_idx))
    %doesn't match any of the existing groups - create a new one
    matching_groups=[matching_groups; ranking_order];
    group_idx=nr_groups+1;
end

%end addToMatchingGroups
end

function [ranking_order group_idx]=getRankingOrder(cur_shape_params,nearby_shape_params,nearby_ranks,shape_params,...
    tracks,matching_groups,track_struct,bUseDirection)
%we need to figure out which parameters to use first when trying to match
%this cell to a track - this can be done if the cell can be assigned to a
%matching group. if not we'll assign a default ranking_order. determine if
%we need a distance-biased or direction-biased ranking order
distanceCol=1;
angleCol=2;
tracks_layout=track_struct.TracksLayout;
start_params_col=tracks_layout.AreaCol;
end_params_col=tracks_layout.SolCol;
group_id_col=tracks_layout.MatchGroupIDCol;
[dummy closest_distance_idx]=min(nearby_ranks(:,distanceCol));
[dummy closest_angle_idx]=min(nearby_ranks(:,angleCol));
bDirection=false;
bDistance=false;
if (closest_angle_idx~=closest_distance_idx)
    %nearest distance and angle point to different cells
    %use the other parameters to pick which one is right
    angle_score=sum(nearby_ranks(closest_angle_idx,:)==1);
    dist_score=sum(nearby_ranks(closest_distance_idx,:)==1);
    if (abs(angle_score-dist_score)>2)
        %we have a clear favorite
        if (angle_score<dist_score)
            if (bUseDirection)
                %use direction matching groups
                if (~isempty(matching_groups))
                    matching_groups=matching_groups(matching_groups(:,1)==2,:);
                end
                bDirection=true;
            end
        else
            %use distance matching groups
            if (~isempty(matching_groups))
                matching_groups=matching_groups(matching_groups(:,1)==1,:);
            end
            bDistance=true;
        end
    else
        %no clear favorite - use more details
        %if one of the cells is a lot closer than the others use distance
        distances_sorted=sort(nearby_shape_params(:,distanceCol));
        dist_ratio=distances_sorted(1)/distances_sorted(2);
        if ((distances_sorted(2)>track_struct.MinSecondDistance)&&(dist_ratio<track_struct.MaxDistRatio))
            %use distance
            %use distance matching groups
            if (~isempty(matching_groups))
                matching_groups=matching_groups(matching_groups(:,1)==1,:);
            end
            bDistance=true;
        end
        %if one angle is within 20 degress of the previous direction and
        %all other angles are further than 20 degrees from our angle use
        %direction
        angle_diffs_sorted=sort(nearby_shape_params(:,2));
        max_angle_diff=track_struct.MaxAngleDiff;
        if ((angle_diffs_sorted(1)<max_angle_diff)&&(abs(angle_diffs_sorted(1)-angle_diffs_sorted(2))>max_angle_diff)&&bUseDirection)
            %use direction matching groups
            if (~isempty(matching_groups))
                matching_groups=matching_groups(matching_groups(:,1)==2,:);
            end
            bDirection=true;
        end
    end
end

if (isempty(matching_groups))
    if (bDistance)
        ranking_order=track_struct.DistanceRankingOrder;
    elseif (bDirection)
        if (bDistance)
            ranking_order=track_struct.UnknownRankingOrder;
        else
            ranking_order=track_struct.DirectionRankingOrder;
        end
    else
        ranking_order=track_struct.UnknownRankingOrder;
    end    
    group_idx=0;
    return;
end
nr_groups=size(matching_groups,1);
group_diff=zeros(nr_groups,end_params_col-start_params_col+1);
cur_params=cur_shape_params(:,1:end_params_col-start_params_col+1);
for i=1:nr_groups
    group_params_idx=(tracks(:,group_id_col)==i);
    group_params_1=tracks(group_params_idx,start_params_col:end_params_col);
    group_params_idx=(shape_params(:,group_id_col-start_params_col+1)==i);
    group_params=[group_params_1; shape_params(group_params_idx,1:(end_params_col-start_params_col+1))];
    group_stats=mean(group_params,1);
    group_diff(i,:)=abs(group_stats-cur_params);
end
[dummy sort_idx]=sort(group_diff);
ranks_sum=sum(sort_idx,2);
[dummy group_idx]=min(ranks_sum);
ranking_order=matching_groups(group_idx,:);

%end getRankingOrder
end

function [tracks_sorted sort_idx track_scores]=sortTracks(track_ranks,tracks,ranking_order,params_weights)
%sort the tracks according to ranking order
nr_tracks=size(track_ranks,1);
if (nr_tracks==1)
    tracks_sorted=tracks;
    sort_idx=1;
    track_scores=1;
    return;
end
track_ranks_by_relevance=track_ranks(:,ranking_order);
weighted_track_ranks=track_ranks_by_relevance.*repmat(params_weights,nr_tracks,1);
track_scores=sum(weighted_track_ranks,2);
[dummy sort_idx]=sort(track_scores);
tracks_sorted=tracks(sort_idx,:);

%end sortTracks
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

function b_path_goes_through_a_cell=pathGoesThroughACell(cells_lbl, prev_cells_lbl, cur_id, prev_id, bkg_id)
cur_pxls=cells_lbl==cur_id;
prev_pxls=prev_cells_lbl==prev_id;
and_pxls=cur_pxls&prev_pxls;
if (max(and_pxls(:)==1))
    %the current and previous positions overlap to some extent
    b_path_goes_through_a_cell=false;
    return;
end
%the positions do not overlap get the perimeter pixels
%crop the boxes otherwise bwboundaries will be really slow
[cur_pxls_1 cur_pxls_2]=find(cur_pxls);
[prev_pxls_1 prev_pxls_2]=find(prev_pxls);
min_1=min([cur_pxls_1; prev_pxls_1]);
max_1=max([cur_pxls_1; prev_pxls_1]);
min_2=min([cur_pxls_2; prev_pxls_2]);
max_2=max([cur_pxls_2; prev_pxls_2]);
cur_pxls=cur_pxls(min_1:max_1,min_2:max_2);
prev_pxls=prev_pxls(min_1:max_1,min_2:max_2);
cur_perim_pixels=bwboundaries(cur_pxls,'noholes');
cur_perim_pixels=cur_perim_pixels{1};
prev_perim_pixels=bwboundaries(prev_pxls,'noholes');
prev_perim_pixels=prev_perim_pixels{1};
cur_points_nr=size(cur_perim_pixels,1);
prev_points_nr=size(prev_perim_pixels,1);
%compute the pairwise distance matrix between the two sets of points
distance_matrix=zeros(cur_points_nr,prev_points_nr);
for i=1:cur_points_nr
    point_mat=repmat(cur_perim_pixels(i,:),prev_points_nr,1);
    distance_matrix(i,:)=hypot(prev_perim_pixels(:,1)-point_mat(:,1),prev_perim_pixels(:,2)-point_mat(:,2));
end
min_val=min(distance_matrix(:));
[cur_point_idx prev_point_idx]=find(distance_matrix==min_val,1);
closest_cur_point=cur_perim_pixels(cur_point_idx,:)+[min_1 min_2];
closest_prev_point=prev_perim_pixels(prev_point_idx,:)+[min_1 min_2];
coord_1_len=abs(closest_cur_point(1)-closest_prev_point(1));
coord_2_len=abs(closest_cur_point(2)-closest_prev_point(2));
if (coord_1_len>coord_2_len)
    if (closest_cur_point(1)>closest_prev_point(1))
        coord_1=round([closest_prev_point(1) closest_cur_point(1)]);
        coord_2=round([closest_prev_point(2) closest_cur_point(2)]);
    else
        coord_1=round([closest_cur_point(1) closest_prev_point(1)]);
        coord_2=round([closest_cur_point(2) closest_prev_point(2)]);
    end
    coord_1_interp=coord_1(1):coord_1(2);
    coord_2_interp=round(interp1q(coord_1',coord_2',coord_1_interp')');
else
    if (closest_cur_point(2)>closest_prev_point(2))
        coord_1=round([closest_prev_point(1) closest_cur_point(1)]);
        coord_2=round([closest_prev_point(2) closest_cur_point(2)]);
    else
        coord_1=round([closest_cur_point(1) closest_prev_point(1)]);
        coord_2=round([closest_cur_point(2) closest_prev_point(2)]);
    end
    coord_2_interp=coord_2(1):coord_2(2);
    coord_1_interp=round(interp1q(coord_2',coord_1',coord_2_interp')');
end
img_sz=size(cells_lbl);
coord_lin=sub2ind(img_sz,coord_1_interp,coord_2_interp);
lbl_ids=unique(prev_cells_lbl(coord_lin));
lbl_ids(lbl_ids==prev_id)=[];
lbl_ids(lbl_ids==bkg_id)=[];
b_path_goes_through_a_cell=~isempty(lbl_ids);

%end pathGoesThroughACell
end


function [nearby_tracks_sorted group_idx matching_groups]=getNearbyTracksSorted(cur_id,cells_centroids,shape_params,track_struct...
    ,cur_tracks,prev_tracks,search_radius,matching_groups,tracks,params_coeff_var)
%get the tracks in the local nhood of this cell sorted by matching scores
hugeNbr=1e6;
cur_cell_centroid=cells_centroids(cur_id,:);
tracks_layout=track_struct.TracksLayout;
areaCol=tracks_layout.AreaCol;
solCol=tracks_layout.SolCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
params_for_sure_match=track_struct.NrParamsForSureMatch;
min_reliable_params=params_for_sure_match;
group_idx=0;

cur_shape_params=shape_params(cur_id,:);
param_weights=track_struct.DefaultParamWeights;
unknown_param_weights=track_struct.UnknownParamWeights;
dist_to_tracks=hypot(cur_tracks(:,centroid1Col)-cur_cell_centroid(1),...
    cur_tracks(:,centroid2Col)-cur_cell_centroid(2));
nearby_tracks_idx=(dist_to_tracks<search_radius);
%keep only tracks in the current search nhood
dist_to_tracks=dist_to_tracks(nearby_tracks_idx);
nearby_tracks=cur_tracks(nearby_tracks_idx,:);
if (isempty(nearby_tracks))
    nearby_tracks_sorted=[];
else
    %rank the tracks by how close their features are to the features of the
    %current cell
    %try to get previous cell travel direction if possible
    if (~isempty(prev_tracks))
        prev_nearby_tracks_idx=ismember(prev_tracks(:,trackIDCol),nearby_tracks(:,trackIDCol));
        prev_nearby_tracks=prev_tracks(prev_nearby_tracks_idx,:);
        if isempty(prev_nearby_tracks)
            prev_tracks_centroids=[];
        else
            nr_prev_tracks=size(prev_nearby_tracks,1);
            nr_cur_tracks=size(nearby_tracks,1);
            prev_tracks_centroids=zeros(nr_cur_tracks,2);
            if (nr_prev_tracks==nr_cur_tracks)
                preexisting_tracks_idx=true(nr_cur_tracks,1);
            else
                preexisting_tracks_idx=ismember(nearby_tracks(:,trackIDCol),prev_nearby_tracks(:,trackIDCol));
            end
            preexisting_tracks=nearby_tracks(preexisting_tracks_idx,:);
            %match order of tracks
            [dummy sort_cur_tracks_idx]=sort(preexisting_tracks(:,trackIDCol));
            [dummy sort_prev_tracks_idx]=sort(prev_nearby_tracks(:,trackIDCol));
            match_tracks_idx=sort_prev_tracks_idx(sort_cur_tracks_idx);
            prev_nearby_tracks=prev_nearby_tracks(match_tracks_idx,:);
            prev_nearby_tracks_centroids=prev_nearby_tracks(:,centroid1Col:centroid2Col);
            cur_nearby_tracks_centroids=preexisting_tracks(:,centroid1Col:centroid2Col);
            prev_tracks_centroids(preexisting_tracks_idx,:)=prev_nearby_tracks_centroids;            
        end
    else
        prev_tracks_centroids=[];
    end
    
    if isempty(prev_tracks_centroids)
        b_use_direction=false;
        %i'm assuming areaCol is the first param column and solCol the last
        cell_ranking_params=[min(dist_to_tracks) cur_shape_params(:,1:(solCol-areaCol+1))];
        tracks_ranking_params=[dist_to_tracks nearby_tracks(:,areaCol:solCol)];
        %sort the tracks by ranking tracks in pairs to the cell instead of
        %all tracks at once. this prevents false best matching tracks.
        tracks_ranks=rankParams(cell_ranking_params,tracks_ranking_params);
        ranking_order=getRankingOrder(cell_ranking_params,tracks_ranking_params,tracks_ranks,shape_params,tracks,...
            matching_groups,track_struct,b_use_direction);        
        group_idx=0;
        [tracks_params_sorted sort_idx]=sortManyToOneUsingPairs(cell_ranking_params,tracks_ranking_params,...
            b_use_direction,unknown_param_weights,param_weights,ranking_order,group_idx);
        %rank the best and second best matching track        
    else
        b_use_direction=true;
        prev_tracks_directions=atan2(abs(cur_nearby_tracks_centroids(:,2)-prev_nearby_tracks_centroids(:,2)),...
            abs(cur_nearby_tracks_centroids(:,1)-prev_nearby_tracks_centroids(:,1)));
        cur_possible_track_directions=atan2(abs(cur_cell_centroid(2)-cur_nearby_tracks_centroids(:,2)),...
            abs(cur_cell_centroid(1)-cur_nearby_tracks_centroids(:,1)));
        directions_diff=zeros(nr_cur_tracks,1);
        directions_diff(preexisting_tracks_idx)=abs(cur_possible_track_directions-prev_tracks_directions);
        directions_diff(~preexisting_tracks_idx)=hugeNbr;
        %i'm assuming areaCol is the first param column and solCol the last
        cell_ranking_params=[min(dist_to_tracks) 0 cur_shape_params(:,1:(solCol-areaCol+1))];
        tracks_ranking_params=[dist_to_tracks directions_diff nearby_tracks(:,areaCol:solCol)];
        tracks_ranks=rankParams(cell_ranking_params,tracks_ranking_params);
        [ranking_order group_idx]=getRankingOrder(cell_ranking_params,tracks_ranking_params,tracks_ranks,shape_params,tracks...
            ,matching_groups,track_struct,b_use_direction);
        %sort the tracks by ranking tracks in pairs to the cell instead of
        %all tracks at once. this prevents false best matching tracks.
        [tracks_params_sorted sort_idx]=sortManyToOneUsingPairs(cell_ranking_params,tracks_ranking_params,...
            b_use_direction,unknown_param_weights,param_weights,ranking_order,group_idx);
        %figure out if we have a track that is a sure match to the cell
        if (length(sort_idx)==1)
            b_sure_match=true;
            pair_ranks=rankParams(cell_ranking_params,tracks_params_sorted);
        else
            %rank the best and second best matching track
            pair_ranks=rankParams(cell_ranking_params,tracks_params_sorted(1:2,:));            
            nr_best_match_params=sum(pair_ranks(1,:)==1);
            if (nr_best_match_params>=params_for_sure_match)
                b_sure_match=true;
            else
                b_sure_match=false;
            end
        end
        if (b_sure_match)
            %this track is a sure match-we'll use it to figure out which
            %parameters work best to assign other cells
            if (length(sort_idx)==1)
                [dummy matching_groups group_idx]=addToMatchingGroups(matching_groups,cell_ranking_params,...
                    tracks_params_sorted,params_coeff_var,1,min_reliable_params,pair_ranks, track_struct);
            else
                [dummy matching_groups group_idx]=addToMatchingGroups(matching_groups,cell_ranking_params,...
                    tracks_params_sorted(1:2,:),params_coeff_var,1,min_reliable_params,pair_ranks, track_struct);
            end
        else
            if (length(sort_idx)==1)
                [dummy group_idx]=getRankingOrder(cell_ranking_params,tracks_params_sorted,pair_ranks,shape_params,...
                    tracks,matching_groups,track_struct,true);
            else
                    [dummy group_idx]=getRankingOrder(cell_ranking_params,tracks_params_sorted(1:2,:),pair_ranks,shape_params,...
                    tracks,matching_groups,track_struct,true);
            end
        end                
    end
    nearby_tracks_sorted=nearby_tracks(sort_idx,:);
end


%end getNearbyTracksSorted
end

function pair_scores=getPairScoresToSingle(pair_params,single_params,b_use_direction,unknown_param_weights,...
    param_weights,pair_ranking_order,pair_group_idx)
%see which one of two cells is a better match for a track or which of two tracks is a better match for a cell. this has to
%be done one cell pair at a time otherwise the best cell/track may not be picked
assert(size(pair_params,1)==2);
pair_ranks=rankParams(single_params,pair_params);
if (pair_group_idx==0)
    if (b_use_direction)
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,pair_ranking_order,unknown_param_weights);
    else
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,...
            pair_ranking_order(pair_ranking_order<max(pair_ranking_order)),unknown_param_weights(1:end-1));
    end
else
    if (b_use_direction)
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,pair_ranking_order,param_weights);
    else
        [dummy dummy2 pair_scores]=sortTracks(pair_ranks,pair_params,...
            pair_ranking_order(pair_ranking_order<max(pair_ranking_order)),param_weights(1:end-1));
    end
end

%end getPairScoresToSingle
end

function [many_params_sorted sort_idx]=sortManyToOneUsingPairs(single_params, many_params,b_use_direction,unknown_param_weights,...
    param_weights,ranking_order,matching_group_idx)
%sort tracks by how well they match a particular cell or cells by how well
%they match a particular track. look at one pair at a time so each
%track/cell is pitted against another individually otherwise the best
%matching track/cell might not be picked. when ranking all the
%cells/tracks at once we have situations where the cell/tracks that has the
%most parameters matching is not the best match due to other poorly
%matching cells/tracks robbing parameter matches from the true best matching cell. by
%matching them head to head this situation is avoided.
many_nr=size(many_params,1);
many_params_sorted=many_params;
sort_idx=[1:many_nr]';
%can't do a straight insertion sort or any sorting algorithm that doesn't
%compare each element with every other element because for track rankings
%a<b and b<c does not imply a<c
for i=1:many_nr-1    
    for j=i:many_nr
        param1=many_params_sorted(j,:);
        sort1=sort_idx(j);
        b_smallest=true;
        for k=i:many_nr
            if (j==k)
                continue;
            end
            param2=many_params_sorted(k,:);            
            many_scores=getPairScoresToSingle([param1;param2],single_params,b_use_direction,unknown_param_weights,...
                param_weights,ranking_order,matching_group_idx);
            if (many_scores(2)<many_scores(1))
                %this cannot be the smallest element
                b_smallest=false;
                break;
            end
        end
        if (b_smallest)
            if (i~=j)
                param2=many_params_sorted(i,:);
                sort2=sort_idx(i);
                many_params_sorted(i,:)=param1;
                sort_idx(i)=sort1;
                many_params_sorted(j,:)=param2;
                sort_idx(j)=sort2;
            end
            break;
        end
    end
end

%end sortManyToOneUsingPairs
end

function best_match_id=getBetterMatchToTrack(cur_track,cells_shape_params,cells_centroids,cells_ids,prev_tracks,matching_groups,...
    track_struct, cells_lbl, prev_cells_lbl)
%figure out which cell of a pair is a better match for the track this
%should only be used with cell pairs otherwise is meaningless
assert(size(cells_shape_params,1)==2);
%figure out which cell is a better match for this track

tracks_layout=track_struct.TracksLayout;
areaCol=tracks_layout.AreaCol;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
groupIDCol=tracks_layout.MatchGroupIDCol;
solCol=tracks_layout.SolCol;
param_weights=track_struct.DefaultParamWeights;
unknown_param_weights=track_struct.UnknownParamWeights;


track_centroid=cur_track(centroid1Col:centroid2Col);
dist_to_cells=hypot(cells_centroids(:,1)-track_centroid(1), cells_centroids(:,2)-track_centroid(2));
if (isempty(prev_tracks))
    prev_track_centroid=[];
else
    prev_track_centroid=prev_tracks(prev_tracks(:,trackIDCol)==cur_track(:,trackIDCol),centroid1Col:centroid2Col);
end
if isempty(prev_track_centroid)
    track_params=[min(dist_to_cells) cur_track(areaCol:solCol)];
    cells_params=[dist_to_cells cells_shape_params(:,1:solCol-areaCol+1)];
    b_use_direction=false;
else
    prev_angle=atan2(abs(track_centroid(2)-prev_track_centroid(2)), abs(track_centroid(1)-prev_track_centroid(1)));
    possible_angles=atan2(abs(track_centroid(2)-cells_centroids(:,2)), abs(track_centroid(1)-cells_centroids(:,1)));
    track_params=[min(dist_to_cells) prev_angle cur_track(areaCol:solCol)];
    cells_params=[dist_to_cells possible_angles cells_shape_params(:,1:solCol-areaCol+1)];
    b_use_direction=true;
end

group_idx=cur_track(:,groupIDCol);
if (group_idx==0)
    ranking_order=track_struct.UnknownRankingOrder;    
else
    ranking_order=matching_groups(group_idx,:);
end
pair_scores=getPairScoresToSingle(cells_params,track_params,b_use_direction,unknown_param_weights,...
    param_weights,ranking_order,group_idx);
best_match_id=[];
if (pair_scores(1)==pair_scores(2))
    %neither cell is a better match to the track
    return;
end

track_lbl_id=getLabelId(prev_cells_lbl, track_centroid);
if (pair_scores(1)<pair_scores(2))
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(1), track_lbl_id, 0))
        best_match_id=cells_ids(1);
        return;
    end
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(2), track_lbl_id, 0))
        best_match_id=cells_ids(2);
        return;
    end
else
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(2), track_lbl_id, 0))
        best_match_id=cells_ids(2);
        return;
    end
    if (~pathGoesThroughACell(cells_lbl, prev_cells_lbl, cells_ids(1), track_lbl_id, 0))
        best_match_id=cells_ids(1);
        return;
    end
end
    
%end getBetterMatchToTrack
end

function b_cell_can_get_another_track=canCellGetAnotherTrack(cur_id,nearby_tracks_sorted,prev_cells_lbl,cells_lbl,...
    track_struct,trackAssignments,shape_params,cells_centroids,prev_tracks,matching_groups,b_bumping_allowed)
if (isempty(nearby_tracks_sorted))
    b_cell_can_get_another_track=false;
    return;
end
tracks_layout=track_struct.TracksLayout;
centroid1Col=tracks_layout.Centroid1Col;
centroid2Col=tracks_layout.Centroid2Col;
trackIDCol=tracks_layout.TrackIDCol;
b_found_track=false;
for i=1:size(nearby_tracks_sorted,1)
    track_lbl_id=getLabelId(prev_cells_lbl,nearby_tracks_sorted(i,centroid1Col:centroid2Col));
    if (pathGoesThroughACell(cells_lbl,prev_cells_lbl,cur_id,track_lbl_id,0))
        continue;
    end
    if (isempty(trackAssignments))
        track_idx=[];
    else        
        track_idx=find(trackAssignments(:,1)==nearby_tracks_sorted(i,trackIDCol),1);
    end
    if (isempty(track_idx))
        b_found_track=true;
        break;
    else
        if (~b_bumping_allowed)
            %not allowed to bump other cells
            continue;
        end
        test_id=trackAssignments(track_idx,2);
        %which cell is prefered by the track?
        test_shape_params=[shape_params(cur_id,:); shape_params(test_id,:)];
        test_cells_centroids=[cells_centroids(cur_id,:); cells_centroids(test_id,:)];
        %sort the two cells with respect of their goodness-of-fit to the
        %track
        preferred_cell_id=getBetterMatchToTrack(nearby_tracks_sorted(i,:),test_shape_params,test_cells_centroids,...
            [cur_id;test_id],prev_tracks,matching_groups,track_struct,cells_lbl,prev_cells_lbl);
        if (isempty(preferred_cell_id)||(preferred_cell_id==test_id))
            continue;
        else
            %found another track which this cell can use
            b_found_track=true;
            break;
        end
    end
end
if (b_found_track)
    b_cell_can_get_another_track=true;
else
    b_cell_can_get_another_track=false;
end

%end canCellGetAnotherTrack
end
