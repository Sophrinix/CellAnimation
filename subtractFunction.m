function output_args=subtractFunction(input_args)
%Usage
%This module subtracts one variable from another.
%
%Input Structure Members
%Number1 - The first variable.
%Number2 - The variable to be subtracted.
%
%Output Structure Members
%Difference - The result of the subtraction.


arg_1=input_args.Number1.Value;
arg_2=input_args.Number2.Value;
output_args.Difference=(arg_1-arg_2);

%end addFunction
end
