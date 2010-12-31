function output_args=isEmptyFunction(input_args)
%wrapper module for Matlab isempty function
output_args.Boolean=isempty(input_args.TestVariable.Value);

%end is_empty_function
end