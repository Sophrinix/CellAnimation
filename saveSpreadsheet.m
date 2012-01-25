function output_args=saveSpreadsheet(input_args)
%module to save the ancestry records to spreadsheets
% Input Structure Members
% Columns – The matrix containing the ancestry data.
% ColumnHeaders - Array containing column header names.
% XlsFile – Path to the location where the spreadsheet will be saved.
% Output Structure Members
% None.

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