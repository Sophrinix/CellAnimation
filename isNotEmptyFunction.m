function output_args=isNotEmptyFunction(input_args)
%module wrapper for is not empty Matlab function
output_args.Boolean=~isempty(input_args.TestVariable.Value);

%end is_empty_function
end