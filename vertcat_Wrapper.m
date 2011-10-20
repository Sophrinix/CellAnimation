function output_args=vertcat_Wrapper(input_args)
%wrapper module for matlab vertcat function
%Input Structure Members
%Matrix1 - The first matrix to be joined.
%Matrix2 - The second matrix to be joined.
%Output Structure Members
%Matrix - The joined matrix.

output_args.Matrix=vertcat(input_args.Matrix1.Value, input_args.Matrix2.Value);

end