function [cyto_lbl nuclei_lbl]=segment_nuclei(img_to_proc,track_struct)
%IMPORTANT - need to use img_cells to calculate a median brightness value
%and then visit each blob and rescale its intensity so that its average
%intensity matches the median intensity of the image. this way i will
%eliminate all uneven illumination

%minimum area of the two resulting polygons for which i will accept a cut
% polygon_area=500;
%minimum blob area for which i will not remove it from a thresholded image
% blob_area=150; %for 10x
% blob_area=300; %for 20x ht1080
% avg_vol=1000; %cubic microns

img_to_proc_norm=imnorm(img_to_proc,'uint16');
img_level_1=impyramid(img_to_proc_norm,'reduce');
img_sz=size(img_level_1);
img_cyto=zeros(img_sz);
img_nucl=zeros(img_sz);
bClearBorder=track_struct.bClearBorder;
clearBorderDist=track_struct.ClearBorderDist;
bCytoLocalAvg=track_struct.bCytoLocalAvg;
bNuclLocalAvg=track_struct.bNuclLocalAvg;

if (bCytoLocalAvg||bNuclLocalAvg)
    avg_filter=fspecial('disk',10);
    img_avg=imfilter(img_level_1,avg_filter,'replicate');
    if (bCytoLocalAvg)
        img_cyto_local_avg_bw=generateBinImgUsingLocAvg(img_level_1, img_avg, track_struct.CytoBrightThreshold,...
            bClearBorder,clearBorderDist);
        img_cyto=img_cyto|img_cyto_local_avg_bw;
    end
    if (bNuclLocalAvg)
        img_nucl_local_avg_bw=generateBinImgUsingLocAvg(img_level_1, img_avg, track_struct.NuclBrightThreshold,...
            bClearBorder,clearBorderDist);
        img_nucl=img_nucl|img_nucl_local_avg_bw;
    end  
end

bCytoGrad=track_struct.bCytoGrad;
bNuclGrad=track_struct.bNuclGrad;
bSmoothContours=track_struct.bSmoothContours;
if (bCytoGrad||bNuclGrad)
    [grad_x grad_y]=gradient(double(img_level_1));
    grad_mag=sqrt(grad_x.^2+grad_y.^2);
    if (bCytoGrad)
        img_cyto_grad_bw=generateBinImgUsingGradient(grad_mag,track_struct.CytoGradThreshold,bClearBorder,...
            clearBorderDist,bSmoothContours);
        img_cyto=img_cyto|img_cyto_grad_bw;
    end
    if (bNuclGrad)
        img_nucl_grad_bw=generateBinImgUsingGradient(grad_mag,track_struct.NuclGradThreshold,bClearBorder,...
            clearBorderDist,bSmoothContours);
        img_nucl=img_nucl|img_nucl_grad_bw;
    end 
end

bCytoInt=track_struct.bCytoInt;
bNuclInt=track_struct.bNuclInt;
if (bCytoInt||bNuclInt)
    if (bCytoInt)
        img_cyto_int_bw=generateBinImgUsingGlobInt(img_level_1,track_struct.CytoIntThreshold,bClearBorder,...
            clearBorderDist);
        img_cyto=img_cyto|img_cyto_int_bw;
    end
    if (bNuclInt)
        img_nucl_int_bw=generateBinImgUsingGlobInt(img_level_1,track_struct.NuclIntThreshold,bClearBorder,...
            clearBorderDist);
        img_nucl=img_nucl|img_nucl_int_bw;
    end
end

% if (track_struct.bContourLink)
%     grad_fill_lbl=bwlabeln(img_grad_clean);
%     grad_fill_props=regionprops(grad_fill_lbl,'Solidity');
%     broken_idx=find([grad_fill_props.Solidity] < 0.7);
%     broken_lbl = ismember(grad_fill_lbl, broken_idx);
%     img_broken_cells=broken_lbl==1;
%     %do a skiz which we'll use later to separate touching cells
%     img_dist=bwdist(img_broken_cells);
%     broken_cells_skiz=watershed(img_dist)==0;
%     img_broken_cells_dil=bwdist(img_broken_cells)<5;
%     img_cells_to_fix=img_broken_cells_dil&img_grad_bw;
%     % l1=bwmorph(img_cells_to_fix,'thin',Inf);
%     l1=bwperim(img_cells_to_fix);
%     %tensor voting to fill in contours
% %     T = find_features(l1,3); %bf
%     T = find_features(l1,link_dist); %bf
%     % T = find_features(l1,1); %fl
%     [e1,e2,l1,l2] = convert_tensor_ev(T);
%     z = l1-l2;
% 
%     img_fixed_cells=z>0.3;
%     img_neg=~img_fixed_cells;
%     %fill holes smaller than a certain size;
%     holes_lbl=bwlabeln(img_neg);
%     holes_props=regionprops(holes_lbl,'Area');
%     small_holes_idx=find([holes_props.Area] < 20);
%     small_holes_lbl=ismember(holes_lbl, small_holes_idx);
%     small_holes_bw=small_holes_lbl>0;
%     img_fixed_cells=img_fixed_cells|small_holes_bw;
%     img_fixed_cells=imopen(img_fixed_cells,strel('diamond',2));
%     %clean the fixed cells
%     img_fixed_cells=bwareaopen(img_fixed_cells,min_blob_area);
%     %use the skiz to separate cells which were separate but are now touching
%     img_fixed_cells=img_fixed_cells&(~broken_cells_skiz);
%     %put the good cells and the fixed cells together
%     img_cells=img_cells|img_fixed_cells;
% end

% if (track_struct.bMaxEcc)
%     cells_lbl=bwlabeln(img_cells);
%     cells_props=regionprops(cells_lbl,'Eccentricity');
%     cells_idx=find([cells_props.Eccentricity] < max_cell_ecc);
%     img_cells=ismember(cells_lbl, cells_idx);
% end



clear img_avg
clear img_cyto_local_avg_bw
clear img_nucl_local_avg_bw
clear img_cyto_grad_bw
clear img_nucl_grad_bw
clear img_cyto_int_bw
clear img_nucl_int_bw


%bring it back to original size - use nearest as interpolation will mess up
%the label
% cells_lbl=imresize(cells_lbl,2,'nearest');
img_nucl=imfill(img_nucl,'holes');
min_nucl_area=track_struct.MinNuclArea;
img_nucl=bwareaopen(img_nucl,min_nucl_area);
img_cyto=imfill(img_cyto,'holes');
img_cyto=imreconstruct(img_cyto&img_nucl,img_cyto);
nuclei_lbl=bwlabeln(img_nucl);
cyto_lbl=bwlabeln(img_cyto);

% % start polygonal approximation
l1=track_struct.L1;
l2=track_struct.L2;
l3=track_struct.L3;
alpha1=track_struct.Alpha1;
alpha2=track_struct.Alpha2;
min_pol_area=track_struct.MinPolArea;
approx_dist=track_struct.ApproxDist;
[split_polygons lbl_id]=polygonal_approx(img_nucl,nuclei_lbl,min_pol_area,approx_dist,l1,l2,l3,...
    alpha1,alpha2,false,true);
%eliminate the convex objects from the objects to be split by the watershed
% %assign new label ids to polygons that have been split
% while(~isempty(lbl_id))
%     cur_id=lbl_id(1);
%     cur_idx=find(lbl_id==cur_id);
%     nuclei_nbr=length(cur_idx);
%     if (nuclei_nbr==1)
%         lbl_id(cur_idx)=[];
%          split_polygons(cur_idx)=[];
%         continue;
%     end
%     
%     [unassigned_pxl_idx_1 unassigned_pxl_idx_2]=find(cells_lbl==cur_id);    
%     pol_centroids=zeros(nuclei_nbr,2);
%     for i=1:nuclei_nbr
%        cur_pol=split_polygons{cur_idx(i)};
%        pol_centroids(i,:)=sum(cur_pol)/length(cur_pol);
%     end
%     k_idx=kmeans([unassigned_pxl_idx_1 unassigned_pxl_idx_2],nuclei_nbr,'start',pol_centroids);
%     cur_max=max(cells_lbl(:));
%     for i=2:nuclei_nbr
%         cell_coord_1=unassigned_pxl_idx_1(k_idx==i);
%         cell_coord_2=unassigned_pxl_idx_2(k_idx==i);
%         cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
%         cells_lbl(cell_coord_lin)=cur_max+i-1;
%     end
%     lbl_id(cur_idx)=[];
%     split_polygons(cur_idx)=[];
% end
% % end polygonal approximation


% start watershed poly combined
% start distance watershed
img_dist=bwdist(~img_nucl);
img_dist=-img_dist;
img_dist(~img_nucl)=-Inf;
med_filt_nhood=track_struct.WatershedMed;
ws_lbl=watershed(medfilt2(img_dist,[med_filt_nhood med_filt_nhood]));
% end distance watershed

%marker controlled segmentation
% sobel_filter=fspecial('sobel');
% img_double=double(img_level_1);
% %equalize the cells image intensity
% % for i=1:obj_nr
% %     cur_obj=cells_lbl==i;
% %     cur_median=median(img_double(cur_obj));
% %     %reassign the intensities in the current blob so their median is the median of all the
% %     %cell intensities
% %     img_double(cur_obj)=img_double(cur_obj)*(cells_median/cur_median);
% % end
% grad_mag=sqrt(imfilter(img_double,sobel_filter,'replicate').^2+imfilter(img_double,sobel_filter','replicate').^2);
% internal_markers=imextendedmin(imcomplement(img_double),cells_median./6);
% external_markers=(watershed(bwdist(internal_markers))==0);
% grad_mag_imp=imimposemin(grad_mag,internal_markers|external_markers);
% ws_lbl=watershed(grad_mag_imp);
%end marker controlled segmentation

%determine bkg_ids - have to use area because ws_lbl splits the background
%in two or more pieces
nuclei_props=regionprops(nuclei_lbl,'Area');
nuclei_area=[nuclei_props.Area];
area_max=max(nuclei_area);
ws_props=regionprops(ws_lbl,'Area');
ws_area=[ws_props.Area];
bkg_mask=ismember(ws_lbl,find(ws_area>area_max));
ws_lbl(bkg_mask)=0;
% 
% 
nuclei_nr=max(nuclei_lbl(:));
convex_cells=ismember([1:nuclei_nr],lbl_id);
for i=1:nuclei_nr
    if (convex_cells(i))
        %don't let the watershed split convex blobs
        continue;
    end
    cur_obj=nuclei_lbl==i;
    ws_lbl_obj=ws_lbl(cur_obj);
    ws_cluster_ids=unique(ws_lbl_obj);
    ws_cluster_ids=ws_cluster_ids(ws_cluster_ids>0);
    if(isempty(ws_cluster_ids))
        continue;
    end
    if (length(ws_cluster_ids)==1)
        %the blob is one colony no need to modify cyto_lbl
        continue;
    else
        nr_clusters=length(ws_cluster_ids);        
        [blob_1 blob_2]=find(cur_obj);
        segmentation_idx=clusterdata([blob_1 blob_2], 'maxclust', nr_clusters, 'linkage', 'average');
        %get the areas of the newly segmented blobs
        new_blob_areas=accumarray(segmentation_idx, 1);
        %blobs smaller than our min threshold have to be unsegmented by assigning
        %them to the nearest blob that is larger than minimum blob area
        segmentation_ids=[1:length(new_blob_areas)];
        valid_new_blobs_idx=(new_blob_areas>min_nucl_area);
        valid_areas=new_blob_areas(valid_new_blobs_idx);
        valid_segmentation_ids=segmentation_ids(valid_new_blobs_idx);
        if isempty(valid_segmentation_ids)
            %no valid split
            continue;
        end
        valid_len=length(valid_segmentation_ids);
        if (valid_len==1)
            %only one of the blobs will be large enough so we can't split
            continue;            
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
                segmented_idx_1=blob_1(cur_segmentation_idx);
                segmented_idx_2=blob_2(cur_segmentation_idx);
                valid_centroids(i,:)=[sum(segmented_idx_1./cur_area) sum(segmented_idx_2./cur_area)];
            end
            invalid_len=length(invalid_segmentation_ids);
            %calculate the centroids of the new invalid blobs
            %reassign the invalid segmentations to their nearest valid neighbors
            for i=1:invalid_len
                cur_segmentation_id=invalid_segmentation_ids(i);
                cur_area=invalid_areas(i);
                cur_segmentation_idx=segmentation_idx==cur_segmentation_id;
                segmented_idx_1=blob_1(cur_segmentation_idx);
                segmented_idx_2=blob_2(cur_segmentation_idx);
                cur_centroid=[sum(segmented_idx_1./cur_area) sum(segmented_idx_2./cur_area)];
                dist_to_valid_centroids=hypot(valid_centroids(:,1)-cur_centroid(1),...
                    valid_centroids(:,2)-cur_centroid(2));
                [dummy closest_valid_centroid_idx]=min(dist_to_valid_centroids);
                nearest_valid_id=valid_segmentation_ids(closest_valid_centroid_idx);
                segmentation_idx(segmentation_idx==cur_segmentation_id)=nearest_valid_id;
            end
        end
        nr_clusters=valid_len;        
        cur_max=max(nuclei_lbl(:));        
        for j=2:nr_clusters
            cur_idx=segmentation_idx==valid_segmentation_ids(j);
            cell_coord_1=blob_1(cur_idx);
            cell_coord_2=blob_2(cur_idx);
            cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
            nuclei_lbl(cell_coord_lin)=cur_max+j-1;
        end
    end    
end
%some stray pixels may result after knncalsify - clear them or they will
%cause problems later on


nuclei_nr=max(nuclei_lbl(:));
nuclei_centroids_1=zeros(nuclei_nr,1);
nuclei_centroids_2=zeros(nuclei_nr,1);
for i=1:nuclei_nr
    [cur_obj_1 cur_obj_2]=find(nuclei_lbl==i);
    obj_length=length(cur_obj_1);
    nuclei_centroids_1(i)=sum(cur_obj_1)./obj_length;
    nuclei_centroids_2(i)=sum(cur_obj_2)./obj_length;
end
nuclei_centroids_lin=sub2ind(img_sz,round(nuclei_centroids_1),round(nuclei_centroids_2));
cyto_idx=cyto_lbl(nuclei_centroids_lin);

cells_nr=max(cyto_lbl(:));
for i=1:cells_nr    
    cluster_ids=find(cyto_idx==i);
    nr_clusters=length(cluster_ids);
    if (nr_clusters<2)
        continue;
    end
    %this is assuming the centroids are synched with the nuclei label ids
    training_idx=ismember(nuclei_lbl,cluster_ids);
    [blob_1 blob_2]=find(cyto_lbl==i);
    [training_1 training_2]=find(training_idx);
    training_group=nuclei_lbl(training_idx);
    %we'll use only every fifth point as a training point or we will
    %run out of memory    
    k_idx=knnclassify([blob_1 blob_2],[training_1(1:5:end) training_2(1:5:end)],training_group(1:5:end));    
    cur_max=max(cyto_lbl(:));
    for j=2:nr_clusters
        cell_coord_1=blob_1(k_idx==cluster_ids(j));
        cell_coord_2=blob_2(k_idx==cluster_ids(j));
        cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
        cyto_lbl(cell_coord_lin)=cur_max+j-1;
    end
end
% grad_mag_imp=imimposemin(grad_mag,internal_markers|external_markers);
% ws_lbl=watershed(grad_mag_imp);
%end watershed poly combined


% %start clusters
% obj_nr=max(cells_lbl(:));
% % assign each unassigned pixel in a blob to the closest polygon
% % showmaxfigure(1),imshow(img_to_proc_norm)
% for i=1:obj_nr
%     cur_obj=cells_lbl==i;
%     obj_reduce=0.3;
% %     cur_obj_area=bwarea(cur_obj);
% %     desired_obj_area=45;
% %     equiv_r=sqrt(cur_obj_area/pi);
% %     desired_r=sqrt(desired_obj_area/pi);
% %     obj_reduce=desired_r/equiv_r;
% 
%     simple_obj=imresize(cur_obj, obj_reduce,'nearest');
%     [blob_1 blob_2]=find(simple_obj);
%     if (size(blob_1,1)<2)
%         continue;
%     end
%     [nr_clusters linkage_clusters]=getBlobClusters([blob_1 blob_2],cluster_dist);
%     if (nr_clusters==1)
%         %the blob is one colony no need to modify cells_lbl
%         continue;
%     end
%     %bring the blob coord back to original size
%     cluster_1=blob_1/obj_reduce;
%     cluster_2=blob_2/obj_reduce;
%     [blob_1 blob_2]=find(cur_obj);
%     k_idx=knnclassify([blob_1 blob_2],[cluster_1 cluster_2],linkage_clusters);
%     cluster_ids=[1:nr_clusters];
% 
% 
% 
%     cur_max=max(cells_lbl(:));
%     %use nearest neighbor to assign pixels in each blob based on hierch. clustering on a smaller version of the blob
%     for j=2:nr_clusters
%         cell_coord_1=blob_1(k_idx==cluster_ids(j));
%         cell_coord_2=blob_2(k_idx==cluster_ids(j));
%         cell_coord_lin=sub2ind(img_sz,cell_coord_1,cell_coord_2);
%         cells_lbl(cell_coord_lin)=cur_max+j-1;
%     end
% end
% %end clusters

%resize back to original image size - use nearest approximation to
%preserve the label ids
cyto_props=regionprops(cyto_lbl,'Area');
remove_idx=find([cyto_props.Area] >= track_struct.MinCytoArea);
img_cyto=ismember(cyto_lbl, remove_idx);
cells_nr=max(cyto_lbl(:));
k=0;
cyto_lbl=cyto_lbl.*img_cyto;
for i=1:cells_nr
    cyto_lin=find(cyto_lbl==i);
    if isempty(cyto_lin)
       k=k+1;
    else
       cyto_lbl(cyto_lin)=i-k;
    end    
end
cyto_lbl=imresize(cyto_lbl,2,'nearest');
end %end main function

function img_bw=generateBinImgUsingLocAvg(img_to_proc,img_avg,avg_thresh,bClearBorder,clearBorderDist)
img_bw=img_to_proc>(avg_thresh*img_avg);
if (bClearBorder)
    if (clearBorderDist>1)
        img_bw(1:clearBorderDist-1,1:end)=1;
        img_bw(end-clearBorderDist+1:end,1:end)=1;
        img_bw(1:end,1:clearBorderDist-1)=1;
        img_bw(1:end,end-clearBorderDist+1:end)=1;
    end
    img_bw=imclearborder(img_bw);
end
end %end generateBinImgUsingLocAvg

function img_bw=generateBinImgUsingGradient(grad_mag,grad_thresh,bClearBorder,clearBorderDist,bSmoothCont)
img_bw=grad_mag>grad_thresh;
img_neg=~img_bw;
%fill holes smaller than a certain size;
holes_lbl=bwlabeln(img_neg);
holes_props=regionprops(holes_lbl,'Area');
small_holes_idx=find([holes_props.Area] < 20);
small_holes_lbl=ismember(holes_lbl, small_holes_idx);
small_holes_bw=small_holes_lbl>0;
img_grad_fill=img_bw|small_holes_bw;
if (bSmoothCont)
img_grad_fill=imopen(img_grad_fill,strel('diamond',4));
img_grad_fill=imopen(img_grad_fill,strel('disk',1));
end
if (bClearBorder)
    if (clearBorderDist>1)
        img_grad_fill(1:clearBorderDist-1,1:end)=1;
        img_grad_fill(end-clearBorderDist+1:end,1:end)=1;
        img_grad_fill(1:end,1:clearBorderDist-1)=1;
        img_grad_fill(1:end,end-clearBorderDist+1:end)=1;
    end
    img_grad_fill=imclearborder(img_grad_fill);
end
img_bw=img_grad_fill;
end %end generateBinImgUsingGradient

function img_bw=generateBinImgUsingGlobInt(img_to_proc,glob_thresh,bClearBorder,clearBorderDist)
img_bw=im2bw(img_to_proc,glob_thresh*graythresh(img_to_proc));
if (bClearBorder)
    if (clearBorderDist>1)
        img_bw(1:clearBorderDist-1,1:end)=1;
        img_bw(end-clearBorderDist+1:end,1:end)=1;
        img_bw(1:end,1:clearBorderDist-1)=1;
        img_bw(1:end,end-clearBorderDist+1:end)=1;
    end
    img_bw=imclearborder(img_bw);
end
end %end generateBinImgUsingGlobInt