function []=updateTrackImage(frame_nr,bShowLabels)
global mtr_gui_struct;

file_name_args.FileBase.Value=mtr_gui_struct.ImageFileBase;
file_name_args.NumberFmt.Value=mtr_gui_struct.NumberFormat;
file_name_args.FileExt.Value=mtr_gui_struct.ImgExt;
file_name_args.CurFrame.Value=frame_nr;
file_name_struct=makeImgFileName(file_name_args);

read_image_args.ImageName.Value=file_name_struct.FileName;
read_image_args.ImageChannel.Value='';
image_struct=readImage(read_image_args);

normalize_args.RawImage.Value=image_struct.Image;
normalize_args.IntegerClass.Value='uint16';
image_struct=imNorm(normalize_args);

label_name_args.FileBase.Value=mtr_gui_struct.SegFileRoot;
label_name_args.CurFrame.Value=frame_nr;
label_name_args.NumberFmt.Value=mtr_gui_struct.NumberFormat;
label_name_args.FileExt.Value='.mat';
file_name_struct=makeImgFileName(label_name_args);

load_label_args.MatFileName.Value=file_name_struct.FileName;
label_struct=loadMatFile(load_label_args);

cur_tracks_args.CurFrame.Value=frame_nr;
cur_tracks_args.OffsetFrame.Value=0;
cur_tracks_args.TimeFrame.Value=mtr_gui_struct.TimeFrame;
cur_tracks_args.TimeCol.Value=mtr_gui_struct.TimeCol;
cur_tracks_args.TrackIDCol.Value=mtr_gui_struct.TrackIDCol;
cur_tracks_args.Tracks.Value=mtr_gui_struct.Tracks;
cur_tracks_args.MaxMissingFrames.Value=mtr_gui_struct.MaxMissingFrames;
cur_tracks_args.FrameStep.Value=mtr_gui_struct.FrameStep;
cur_tracks_struct=getCurrentTracks(cur_tracks_args);

overlay_ancestry_args.Image.Value=image_struct.Image;
overlay_ancestry_args.CurrentTracks.Value=cur_tracks_struct.Tracks;
overlay_ancestry_args.CellsLabel.Value=label_struct.cells_lbl;
overlay_ancestry_args.CellsAncestry.Value=mtr_gui_struct.CellsAncestry;
overlay_ancestry_args.CurFrame.Value=frame_nr;
overlay_ancestry_args.ColorMap.Value=mtr_gui_struct.ColorMap;
overlay_ancestry_args.TracksLayout.Value=mtr_gui_struct.TracksLayout;
overlay_ancestry_args.AncestryLayout.Value=mtr_gui_struct.AncestryLayout;
overlay_ancestry_args.ShowLabels.Value=bShowLabels;
overlay_ancestry_struct=overlayAncestry(overlay_ancestry_args);

%display objects image in the objectAxes
mtr_gui_struct.ImageData=overlay_ancestry_struct.Image;
mtr_gui_struct.ImageHandle=image(overlay_ancestry_struct.Image,'Parent',mtr_gui_struct.TracksHandle);
%set the function handle for a mouse click in the objects image
set(mtr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInTrackingFrame');
%update the cells label
mtr_gui_struct.CellsLabel=label_struct.cells_lbl;
mtr_gui_struct.FrameTracks=cur_tracks_struct.Tracks;

%end updateTrackImage
end