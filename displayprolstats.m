function []=displayprolstats(track_struct)

input2=track_struct.ProlDir;
ds=track_struct.DS;
load ([input2 ds 'start_times'])
load ([input2 ds 'split_times'])
load([input2 ds 'cells_generations'])
load([input2 ds 'cells_ids'])
load([input2 ds 'parents_ids'])
column_names='Cells IDs,Parents IDs,Generations,Start Time,Split Time';
all_data=[cells_ids parents_ids cells_generations start_times split_times];
disp('Deleting spreadsheet if it exists...')
output1=track_struct.ProlXlsFile;
delete(output1)
disp('Saving raw data...')

%delimiter has to be added manually to strings
dlmwrite(output1,column_names,'');
dlmwrite(output1,all_data,'-append');
%remove cells that have no parent and cells ending at the last
%frame
% max_split_time=max(split_times)
% remove_cells_idx=(parents_ids==0)|(split_times==max_split_time);
% cells_ids_filtered=cells_ids(~remove_cells_idx);
% cells_generations_filtered=cells_generations(~remove_cells_idx);
% parents_ids_filtered=parents_ids(~remove_cells_idx);
% start_times_filtered=start_times(~remove_cells_idx);
% split_times_filtered=split_times(~remove_cells_idx);

% figure(1), hist(start_times(start_times>min(start_times)))
% xlabel('Time (min)')
% ylabel('Cell numbers')
% title('New Cells')

%remove cells with no offspring
% parents_ids_sorted=sort(parents_ids_filtered);
% filtered_len=length(cells_ids_filtered);
% cells_have_proginy_idx=true(filtered_len,1);
% for i=1:length(cells_ids_filtered)
%     cell_is_parent=find(parents_ids_sorted==cells_ids(i),1);
%     if (isempty(cell_is_parent))        
%         cells_have_proginy_idx(i)=false;
%     end
% end
% cells_ids_filtered=cells_ids_filtered(cells_have_proginy_idx);
% parents_ids_filtered=parents_ids_filtered(cells_have_proginy_idx);
% cells_generations_filtered=cells_generations_filtered(cells_have_proginy_idx);
% start_times_filtered=start_times_filtered(cells_have_proginy_idx);
% split_times_filtered=split_times_filtered(cells_have_proginy_idx);
% 
% filtered_data=[cells_ids_filtered parents_ids_filtered cells_generations_filtered start_times_filtered split_times_filtered];
% disp('Saving filtered data...')
% xlswrite(output1,column_names,'Filtered','A1');
% xlswrite(output1,filtered_data,'Filtered','A2');
% doubling_times_filtered=(split_times_filtered-start_times_filtered)/60;
% figure(1),close(1);
% figure(1), hist(doubling_times_filtered)
% xlabel('Doubling Time')
% ylabel('Number of cells')
% figure(2), hist(split_times(splitting_cells_idx))
% xlabel('Time (min)')
% ylabel('Cell numbers')
% title('Splitting Cells')
% figure(3), hist(split_times(dying_cells_idx))
% xlabel('Time (min)')
% ylabel('Cell numbers')
% title('Dying Cells')

%end function
end