function new_array=flattenCellArray(cell_array)
%take an array that may contain cells and cell arrays and flatten it so it
%only contains cells
new_array={};
for i=1:length(cell_array)
    if (iscell(cell_array{i}))
        new_array=[new_array;flattenCellArray(cell_array{i})];
    else
        new_array=[new_array;cell_array(i)];
    end
end

%end flattenCellArray
end
