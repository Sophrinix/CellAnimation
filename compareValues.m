function output_args=compareValues(input_args)
%compare values module
%compare two values Arg1 and Arg2 using the operator specified in Operation
%and return the result in BooleanOut

switch input_args.Operation.Value
    case '>'
        output_args.BooleanOut=input_args.Arg1.Value>input_args.Arg2.Value;
    case '<'
        output_args.BooleanOut=input_args.Arg1.Value<input_args.Arg2.Value;
    case '>='
        output_args.BooleanOut=input_args.Arg1.Value>=input_args.Arg2.Value;
    case '<='
        output_args.BooleanOut=input_args.Arg1.Value<=input_args.Arg2.Value;
    case '=='
        output_args.BooleanOut=input_args.Arg1.Value==input_args.Arg2.Value;
end