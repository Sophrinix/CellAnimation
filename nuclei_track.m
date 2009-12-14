function []=nuclei_track(well_folder)
img_ext='.tif'
ds='\' %directory symbol
root_folder='f:\test';
img_filebase=[well_folder ds 'DsRed - Confocal - n'];
name_idx=find(well_folder==ds,2,'last');
%generate a unique well name
well_name=well_folder((name_idx(1)+1):end);
well_name(name_idx(2)-name_idx(1))=[];
well_name(well_name==' ')=[];
output_folder=[root_folder ds well_name];
track_dir=[output_folder ds 'track'];
mkdir(track_dir);
seg_file_root=[track_dir ds 'grayscale'];
tracks_file=[track_dir ds 'tracks.mat'];
prol_dir=[output_folder ds 'proliferation'];
mkdir(prol_dir);
prol_file_root=[prol_dir ds 'prol'];
xls_folder=[root_folder ds 'spreadsheets'];
prol_xls_file=[xls_folder ds well_name '.csv'];
shapes_xls_file=[xls_folder ds well_name '_shapes.csv'];
startframe=1
framecount=550
timeframe=6 %minutes
full_track_nuclei(img_filebase,seg_file_root,track_dir,tracks_file,prol_file_root,prol_dir,...
    prol_xls_file,shapes_xls_file,startframe,framecount,timeframe, ds, img_ext);
%end function
end