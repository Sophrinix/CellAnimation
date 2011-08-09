function output_args=getArrayVal(input_args)
%Usage
%This module returns a value or set of values from an array.
%
%Input Structure Members
%Array – Array from which the value is to be extracted.
%Index – The index of the values to be returned.
%
%Output Structure Members
%ArrayVal – Set of values extracted from the array.
%
%Example
%
%get_current_offset.InstanceName='GetCurrentOffset';
%get_current_offset.FunctionHandle=@getArrayVal;
%get_current_offset.FunctionArgs.Array.Value=frame_offsets;
%get_current_offset.FunctionArgs.Index.FunctionInstance='ProcessingLoop';
%get_current_offset.FunctionArgs.Index.OutputArg='LoopCounter';
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,get_cu
%rrent_offset);
%
%…
%
%crop_image.FunctionArgs.XYOffset.FunctionInstance='GetCurrentOffset';
%crop_image.FunctionArgs.XYOffset.OutputArg='ArrayVal';

array=input_args.Array.Value;
output_args.ArrayVal=array(input_args.Index.Value,:);

%end getArrayVal
end
