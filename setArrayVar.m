function output_args=setArrayVar(input_args)
% Usage
% This module is used to set a set of values in an array.
% Input Structure Members
% Array – The array where the values will be entered.
% Index – The index in the array where the values will be entered.
% Var – The set of values that will be entered in the array.
% Output Structure Members
% Array – The array with the new set of values.

array=input_args.Array.Value;
array(input_args.Index.Value,:)=input_args.Var.Value;
output_args.Array=array;

%end setArrayVar
end
