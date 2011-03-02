function output_args=setArrayVar(input_args)
%module to set a value in an array
array=input_args.Array.Value;
array(input_args.Index.Value,:)=input_args.Var.Value;
output_args.Array=array;

%end setArrayVar
end