function output_args=repmat_Wrapper(input_args)
%this a simple wrapper for the MATLAB function repmat
%Matrix - the matrix to be repeated
%RepeatDim - the dimension array indicating how many times the matrix
%should be repeated in each dimension.

A=input_args.Matrix.Value;
rd=input_args.RepeatDim.Value;
output_args.Matrix=repmat(A,rd);

end