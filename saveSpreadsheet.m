function output_args=saveSpreadsheet(input_args)
%module to save the ancestry records

disp('Saving Spreadsheet...')
columns=input_args.Columns.Value;
column_headers=input_args.ColumnHeaders.Value;
xls_file=input_args.XlsFile.Value;
delete(xls_file);
dlmwrite(xls_file,column_headers,'');
dlmwrite(xls_file,columns,'-append');
output_args=[];
disp('Saved!')

%end saveAncestrySpreadsheets
end