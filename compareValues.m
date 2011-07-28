function output_args=compareValues(input_args)
%Usage
%This module is used to compare two numerical values using the specified operation.
%
%Input Structure Members
%Arg1 – First numerical value.
%Arg2 – Second numerical value.
%Operation – String representing the mathematical operation to be performed.
%Currently, ‘>’,’<’,’>=’,’<=’ and ’==’ are supported.
%
%Output Structure Members
%BooleanOut – The result of the operation. Can be either 1 (true) or 0 (false).
%
%Example
%
%label_to_bw_function.InstanceName='LabelToBW';
%label_to_bw_function.FunctionHandle=@compareValues;
%label_to_bw_function.FunctionArgs.Operation.Value='>';
%label_to_bw_function.FunctionArgs.Arg1.FunctionInstance='ReviewSegmentation';
%label_to_bw_function.FunctionArgs.Arg1.OutputArg='LabelMatrix';
%label_to_bw_function.FunctionArgs.Arg2.Value=0;
%functions_list=addToFunctionChain(functions_list,label_to_bw_function);
%
%…
%
%save_bw_image_function.FunctionArgs.SaveData.FunctionInstance='LabelToBW';
%save_bw_image_function.FunctionArgs.SaveData.OutputArg='BooleanOut';

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
