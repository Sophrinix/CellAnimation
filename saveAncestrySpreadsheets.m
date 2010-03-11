function output_args=saveAncestrySpreadsheets(input_args)

tracks=input_args.Tracks.Value;
cells_ancestry=input_args.CellsAncestry.Value;
track_struct=input_args.TrackStruct.Value;
tracks_layout=track_struct.TracksLayout;
trackIDCol=tracks_layout.TrackIDCol;

%sort tracks_with_stats by cell id
[dummy sort_idx]=sort(tracks(:,trackIDCol));
tracks=tracks(sort_idx,:);
column_names=...
    'Cell ID,Time,Centroid 1,Centroid 2,Area,Eccentricity,MajorAxisLength,MinorAxisLength,Orientation,Perimeter,Solidity';
disp('Saving 2D stats...')
xls_file=track_struct.ShapesXlsFile;
delete(xls_file);
dlmwrite(xls_file,column_names,'');
dlmwrite(xls_file,tracks,'-append');
column_names='Cells IDs,Parents IDs,Generations,Start Time,Split Time';
disp('Deleting spreadsheet if it exists...')
xls_file=track_struct.ProlXlsFile;
delete(xls_file);
disp('Saving ancestry data...')
dlmwrite(xls_file,column_names,'');
dlmwrite(xls_file,cells_ancestry,'-append');

output_args=[];

%end saveAncestrySpreadsheets
end