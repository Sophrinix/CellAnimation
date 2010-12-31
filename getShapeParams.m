function output_args=getShapeParams(input_args)
%module to compute the return the 2-d shape parameters of the objects in a
%label matrix
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
for i=1:nr_cells
    blob_ids(i)=getLabelId(blob_lbl,cells_centroids(i,:));
end
%i want the orientation from 0 to 180 instead of -90 to 90 so i can run
%percentages
shape_params=[[cells_props.Area]' [cells_props.Eccentricity]' [cells_props.MajorAxisLength]' ...
    [cells_props.MinorAxisLength]' [cells_props.Orientation]'+90 [cells_props.Perimeter]'...
    [cells_props.Solidity]' blob_ids matching_group_ids];
output_args.ShapeParameters=shape_params;
output_args.Centroids=cells_centroids;

%end getShapeParams
end