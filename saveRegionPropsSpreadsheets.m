function output_args=saveRegionPropsSpreadsheets(input_args)
%Usage
%This module is used to save the shape parameters extracted using the getRegionProps wrapper
%module.
%
%Input Structure Members
%RegionProps – The matrix containing the shape parameters.
%SpreadsheetFileName – The desired file name for the saved file.
%
%Output Structure Members
%None.
%
%Example
%
%save_region_props_function.InstanceName='SaveRegionProps';
%save_region_props_function.FunctionHandle=@saveRegionPropsSpreadsheets;
%save_region_props_function.FunctionArgs.RegionProps.FunctionInstance='GetRegi
%onProps';
%save_region_props_function.FunctionArgs.RegionProps.OutputArg='RegionProps';
%save_region_props_function.FunctionArgs.SpreadsheetFileName.FunctionInstance=
%'MakeSpreadsheetFileName';
%save_region_props_function.FunctionArgs.SpreadsheetFileName.OutputArg='Text';
%functions_list=addToFunctionChain(functions_list,save_region_props_function);

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
