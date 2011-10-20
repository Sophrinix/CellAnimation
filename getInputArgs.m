function input_args=getInputArgs(module_path)
%helper function for assayEditorGUI. extract the input args from the specified module

module_name=module_path(1:(end-2));
switch(module_name)
    case 'forLoop'
        input_args={'EndLoop','IncrementLoop','StartLoop'};
    case 'if_statement'
        input_args={'TestVariable'};
    case 'whileLoop'
        input_args={'TestFunction'};
    otherwise
        module_text=fileread(module_path);
        search_pattern='input_args.(\w*).Value';
        input_tokens=regexp(module_text,search_pattern,'tokens');
        input_args=cellfun(@(x) x{1},input_tokens,'UniformOutput',false);
        input_args=unique(input_args);
end

%end getInputArgs
end