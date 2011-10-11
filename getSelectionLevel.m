function selection_level=getSelectionLevel(selection_text)
%get the level of the chain this module is attached to in the current assay
%get the number of whitespaces
search_pattern=['[^&]*(&nbsp;)*\w*<'];
ws=regexp(selection_text,search_pattern,'tokens');
selection_level=length(ws{1}{1})/12;
if ~strcmp(selection_text(1:9),'<html><i>')
    selection_level=selection_level+1;
end

%end getSelectionLevel
end