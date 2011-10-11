function module_strings=formatModuleStrings(modules_list)
%format module strings for display in listbox
module_strings={};
for i=1:length(modules_list)
    module_strings=[module_strings;formatModuleItem(modules_list{i})];    
end

%end formatModuleString
end