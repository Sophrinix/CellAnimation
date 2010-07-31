function saveTrackingImage()
global mtr_gui_struct;

[file_name path_name]=uiputfile('*.jpg','Save Frame Image');
if (~file_name)
    return;
end
hidden_figure_handle=figure('visible','off');
% copy axes into the new figure
set(hidden_figure_handle,'PaperPositionMode','auto');
subplot('Position', [0 0 1 1]);
hidden_axes=copyobj(mtr_gui_struct.TracksHandle,hidden_figure_handle);
set(hidden_axes, 'units', 'normalized', 'position', [0 0 1 1]);
print(hidden_figure_handle, '-djpeg', [path_name file_name])

%end saveImage
end