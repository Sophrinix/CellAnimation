function [shape_params cells_centroids]=getShapeParams(cells_lbl)
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
for i=1:nr_cells
    blob_ids(i)=getLabelId(blob_lbl,cells_centroids(i,:));
end
shape_params=[[cells_props.Area]' [cells_props.Eccentricity]' [cells_props.MajorAxisLength]' ...
    [cells_props.MinorAxisLength]' [cells_props.Orientation]' [cells_props.Perimeter]'...
    [cells_props.Solidity]' blob_ids];
%end getShapeParams
end