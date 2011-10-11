function output_args=vertcat_Wrapper(input_args)
%wrapper module for matlab vertcat function

output_args.Matrix=vertcat(input_args.Matrix1.Value, input_args.Matrix2.Value);

end