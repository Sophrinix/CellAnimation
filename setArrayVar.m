function output_args=setArrayVar(input_args)
%Usage
%This module is used to set a set of values in an array.
%
%Input Structure Members
%Array – The array where the values will be entered.
%Index – The index in the array where the values will be entered.
%Var – The set of values that will be entered in the array.
%
%Output Structure Members
%Array – The array with the new set of values.
%
%Example
%
%set_offset_function.InstanceName='SetOffset';
%set_offset_function.FunctionHandle=@setArrayVar;
%set_offset_function.FunctionArgs.Array.FunctionInstance='SegmentationLoop';
%set_offset_function.FunctionArgs.Array.InputArg='OffsetArray';
%set_offset_function.FunctionArgs.Index.FunctionInstance='SegmentationLoop';
%set_offset_function.FunctionArgs.Index.OutputArg='LoopCounter';
%set_offset_function.FunctionArgs.Var.FunctionInstance='GetXYCoordinates';
%set_offset_function.FunctionArgs.Var.OutputArg='XYCoords';
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,set_of
%fset_function);
%
%…
%
%image_read_loop.FunctionArgs.OffsetArray.FunctionInstance='SetOffset';
%image_read_loop.FunctionArgs.OffsetArray.OutputArg='Array';

array=input_args.Array.Value;
array(input_args.Index.Value,:)=input_args.Var.Value;
output_args.Array=array;

%end setArrayVar
end
