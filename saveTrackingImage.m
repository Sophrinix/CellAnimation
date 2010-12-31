function saveTrackingImage()
%helper function for manual tracking review module. save the current image
global mtr_gui_struct;

[file_name path_name filter_index]=uiputfile({'*.jpg';'*.tif'},'Save Frame Image');
if (~filter_index)
    return;
end
hidden_figure_handle=figure('visible','off');
% copy axes into the new figure
set(hidden_figure_handle,'PaperPositionMode','auto');
subplot('Position', [0 0 1 1]);
hidden_axes=copyobj(mtr_gui_struct.TracksHandle,hidden_figure_handle);
set(hidden_axes, 'units', 'normalized', 'position', [0 0 1 1]);
switch (filter_index)
    case 1
        print(hidden_figure_handle, '-djpeg', [path_name file_name]);
    case 2
        print(hidden_figure_handle, '-dtiff', '-r300', [path_name file_name]);
end

%end saveImage
end