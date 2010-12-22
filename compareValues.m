function output_args=compareValues(input_args)

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