function output_args=saveAncestrySpreadsheets(input_args)
% Usage
% This module is used to save the tracks and ancestry records spreadsheets.
% Input Structure Members
% CellsAncestry – Matrix containing the ancestry records for the cells in the time-lapse movie.
% ProlXlsFile – The desired file name for the spreadsheet containing the ancestry records.
% ShapesXlsFile – The desired file name for the spreadsheet containing the tracks and shape parameters data.
% Tracks – The tracks matrix to be processed.
% TracksLayout – Matrix describing the order of the columns in the tracks matrix.
% Output Structure Members
% None.


tracks=input_args.Tracks.Value;
cells_ancestry=input_args.CellsAncestry.Value;
tracks_layout=input_args.TracksLayout.Value;
trackIDCol=tracks_layout.TrackIDCol;

%sort tracks_with_stats by cell id
[dummy sort_idx]=sort(tracks(:,trackIDCol));
tracks=tracks(sort_idx,:);
column_names=...
    'Cell ID,Time,Centroid 1,Centroid 2,Area,Eccentricity,MajorAxisLength,MinorAxisLength,Orientation,Perimeter,Solidity';
disp('Saving 2D stats...')
xls_file=input_args.ShapesXlsFile.Value;
save_dir_idx=find(xls_file=='/',1,'last');
save_dir=xls_file(1:(save_dir_idx-1));
if ~isdir(save_dir)
    mkdir(save_dir);
end
delete(xls_file);
dlmwrite(xls_file,column_names,'');
dlmwrite(xls_file,tracks,'-append');
column_names='Cells IDs,Parents IDs,Generations,Start Time,Split Time';
disp('Deleting spreadsheet if it exists...')
xls_file=input_args.ProlXlsFile.Value;
delete(xls_file);
disp('Saving ancestry data...')
dlmwrite(xls_file,column_names,'');
dlmwrite(xls_file,cells_ancestry,'-append');

output_args=[];

%end saveAncestrySpreadsheets
end
