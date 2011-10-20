function output_args=getArrayVal(input_args)
% Usage
% This module returns a value or set of values from an array.
% Input Structure Members
% Array – Array from which the value is to be extracted.
% Index – The index of the values to be returned.
% Output Structure Members
% ArrayVal – Set of values extracted from the array.


array=input_args.Array.Value;
output_args.ArrayVal=array(input_args.Index.Value,:);

%end getArrayVal
end
