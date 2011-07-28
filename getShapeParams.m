function output_args=getShapeParams(input_args)
%Usage
%This module is used to extract the shape parameters (Area,Eccentricity,etc.) of objects in a label
%matrix. Mostly, a wrapper for the MATLAB regionprops function. Adds a blob id to the output so
%that objects that belong to the same blob may be identified at a later time.
%
%Input Structure Members
%LabelMatrix – The label matrix from which the shape parameters will be extracted.
%
%Output Structure Members
%Centroids – The centroids of the objects in the label matrix.
%ShapeParameters – The shape parameters of the objects in the label matrix.
%
%Example
%
%get_shape_params_function.InstanceName='GetShapeParameters';
%get_shape_params_function.FunctionHandle=@getShapeParams;
%get_shape_params_function.FunctionArgs.LabelMatrix.FunctionInstance='IfIsEmpt
%yPreviousCellsLabel';
%get_shape_params_function.FunctionArgs.LabelMatrix.InputArg='CellsLabel';
%if_is_empty_cells_label_functions=addToFunctionChain(if_is_empty_cells_label_
%functions,get_shape_params_function);
%
%…
%
%start_tracks_function.FunctionArgs.ShapeParameters.FunctionInstance='GetShape
%Parameters';
%start_tracks_function.FunctionArgs.ShapeParameters.OutputArg='ShapeParameters
%';

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
