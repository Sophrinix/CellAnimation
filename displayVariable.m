function output_args=displayVariable(input_args)
%module to display a variable name and its value
output_args=[];
disp(input_args.VariableName.Value);
disp(input_args.Variable.Value);

%end displayVariable
end