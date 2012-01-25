function stripped_text=stripHTMLFromString(html_string)
%helper function for assayEditorGUI. get a module ID from a listbox html string
%remove the html code
search_pattern='<html>(?:<\w>)*(?:&nbsp;)*(\w*)(?:</\w>)*</html>';
stripped_text=regexp(html_string,search_pattern,'once','tokens');
stripped_text=stripped_text{1};

%end getIDFromString
end