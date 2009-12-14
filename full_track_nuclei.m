function []=full_track_nuclei(img_filebase,seg_file_root,track_dir,tracks_file,prol_file_root,prol_dir,...
    prol_xls_file,shapes_xls_file,startframe,framecount,timeframe, ds, img_ext)
darren_track(img_filebase,seg_file_root,track_dir,startframe,framecount,timeframe, ds, img_ext);
extract_movie_data(img_filebase,seg_file_root,prol_file_root,prol_dir,tracks_file,startframe,framecount,...
    timeframe,shapes_xls_file, ds, img_ext);
displayprolstats(prol_dir,prol_xls_file, ds);
end