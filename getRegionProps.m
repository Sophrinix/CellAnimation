function output_args=getRegionProps(input_args)
%module to return the region properties of the objects in a
%label matrix. a particular wrapper to regionprops.
cells_lbl=input_args.LabelMatrix.Value;
cells_props=regionprops(cells_lbl,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Orientation','Perimeter','Solidity');
cells_centroids=[cells_props.Centroid]';
centr_len=size(cells_centroids,1);
cells_centroids=[cells_centroids(2:2:centr_len) cells_centroids(1:2:centr_len)];
%i want the orientation from 0 to 180 instead of -90 to 90
region_props=[(1:centr_len/2)' cells_centroids [cells_props.Area]' [cells_props.Eccentricity]' [cells_props.MajorAxisLength]' ...
    [cells_props.MinorAxisLength]' [cells_props.Orientation]'+90 [cells_props.Perimeter]'...
    [cells_props.Solidity]'];
output_args.RegionProps=region_props;

%end getRegionProps
end