function output_args=saveRegionPropsSpreadsheets(input_args)
% Usage
% This module is used to save the shape parameters extracted using the getRegionProps wrapper module.
% Input Structure Members
% RegionProps – The matrix containing the shape parameters.
% SpreadsheetFileName – The desired file name for the saved file.
% Output Structure Members
% None.

region_props=input_args.RegionProps.Value;
%sort tracks_with_stats by cell id
column_names=...
    'Cell ID,Centroid 1,Centroid 2,Area,Eccentricity,MajorAxisLength,MinorAxisLength,Orientation,Perimeter,Solidity';
disp('Saving region props...')
spreadsheet_file=input_args.SpreadsheetFileName.Value;
delete(spreadsheet_file);
dlmwrite(spreadsheet_file,column_names,'');
dlmwrite(spreadsheet_file,region_props,'-append');
output_args=[];

%end saveRegionPropsSpreadsheets
end
