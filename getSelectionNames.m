function selection_names=getSelectionNames()
%helper function for manual tracking review. get a list of selection layer
%names
global mtr_gui_struct;

selection_layers=mtr_gui_struct.SelectionLayers;
selection_names={};
for i=1:length(selection_layers)
    selection_names{i}=selection_layers{i}.Name;
end

%end getSelectionNames
end