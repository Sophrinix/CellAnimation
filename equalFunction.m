function output_args=equalFunction(input_args)
%module to compare two values

arg_1=input_args.Number1.Value;
arg_2=input_args.Number2.Value;
output_args.Boolean=(arg_1==arg_2);

%end addFunction
end