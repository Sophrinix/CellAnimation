function output_args=saveRegionPropsSpreadsheets(input_args)
%module to save the shape properties from getRegionProps
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