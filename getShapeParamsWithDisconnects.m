function output_args=getShapeParamsWithDisconnects(input_args)
cells_lbl=input_args.LabelMatrix.Value;
cells_props=regionprops(cells_lbl,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Orientation','Perimeter','Solidity');
cells_centroids=[cells_props.Centroid]';
centr_len=size(cells_centroids,1);
cells_centroids=[cells_centroids(2:2:centr_len) cells_centroids(1:2:centr_len)];
%also get the blob id of each cell-this helps merge oversegmented
%cells later
cells_bw=cells_lbl>0;
blob_lbl=bwlabeln(cells_bw);
nr_cells=size(cells_centroids,1);
blob_ids=zeros(nr_cells,1);
matching_group_ids=blob_ids;
%i want the orientation from 0 to 180 instead of -90 to 90 so i can run
%percentages
shape_params=[[cells_props.Area]' [cells_props.Eccentricity]' [cells_props.MajorAxisLength]' ...
    [cells_props.MinorAxisLength]' [cells_props.Orientation]'+90 [cells_props.Perimeter]'...
    [cells_props.Solidity]' blob_ids matching_group_ids];

for i=1:nr_cells
    cur_blob=(cells_lbl==i);
    cur_blob_lbl=bwlabeln(cur_blob);
    if max(cur_blob_lbl(:)>1)
        %a blob that consists of more than one piece
        cur_blob_ids=unique(blob_lbl(cur_blob));
        blob_ids(i)=min(cur_blob_ids);
        cur_blob=joinFragmentedBlob(cur_blob);
        cur_blob_lbl=bwlabeln(cur_blob);
        cur_blob_props=regionprops(cur_blob_lbl,'Centroid','Area','Eccentricity',...
            'MajorAxisLength','MinorAxisLength','Orientation',...
            'Perimeter','Solidity');
        shape_params(i,1:(end-2))=[cur_blob_props.Area cur_blob_props.Eccentricity cur_blob_props.MajorAxisLength...
            cur_blob_props.MinorAxisLength (cur_blob_props.Orientation+90) cur_blob_props.Perimeter...
            cur_blob_props.Solidity];
        cells_centroids(i,:)=[cur_blob_props.Centroid(2) cur_blob_props.Centroid(1)];
    else
        blob_ids(i)=getLabelId(blob_lbl,cells_centroids(i,:));
    end    
end

shape_params(:,(end-1))=blob_ids;
output_args.ShapeParameters=shape_params;
output_args.Centroids=cells_centroids;

%end getShapeParams
end