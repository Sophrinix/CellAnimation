function output_args=mergeTracks(input_args)
%module to merge tracks updating the tracks matrix and label matrices
tracks=input_args.Tracks.Value;
tracks_to_be_merged=input_args.TracksToBeMerged.Value;
if isempty(tracks_to_be_merged)
    output_args.Tracks=tracks;
    return;
end

framecount=input_args.FrameCount.Value;
startframe=input_args.StartFrame.Value;
timeframe=input_args.TimeFrame.Value;
seg_file_root=input_args.SegFileRoot.Value;
frame_step=input_args.FrameStep.Value;
number_fmt=input_args.NumberFormat.Value;
tracks_layout=input_args.TracksLayout.Value;
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
            get_shape_params_args.LabelMatrix.Value=cur_blobs_lbl;
            shape_params_output=getShapeParams(get_shape_params_args);
            new_shape_params=shape_params_output.ShapeParameters;
            new_centroid=shape_params_output.Centroids;
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
    cells_lbl=makeContinuousLabelMatrix(cells_lbl);
    save([seg_file_root num2str(curframe,number_fmt)],'cells_lbl');
end

output_args.Tracks=tracks;

%end mergeTracks
end
