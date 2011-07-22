function output_args=getArrayVal(input_args)
%module to return a value in an array

array=input_args.Array.Value;
output_args.ArrayVal=array(input_args.Index.Value,:);

%end getArrayVal
end