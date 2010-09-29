function output_args=addFunction(input_args)
%add two values and return the sum

arg_1=input_args.Number1.Value;
arg_2=input_args.Number2.Value;
output_args.Sum=(arg_1+arg_2);

%end addFunction
end