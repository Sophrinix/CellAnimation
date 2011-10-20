function output_args=addFunction(input_args)
%Usage
%This module adds two variables.
%
%Input Structure Members
%Number1 - The first variable to be added.
%Number2 - The second variable to be added.
%
%Output Structure Members
%Sum - The result of the addition.
%
%Example
%
%get_previous_frame_nr_function.InstanceName='GetPreviousFrameNr';
%get_previous_frame_nr_function.FunctionHandle=@addFunction;
%get_previous_frame_nr_function.FunctionArgs.Number1.FunctionInstance='Segment
%ationLoop';
%get_previous_frame_nr_function.FunctionArgs.Number1.OutputArg='LoopCounter';
%get_previous_frame_nr_function.FunctionArgs.Number2.Value=-1;
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,get_pr
%evious_frame_nr_function);
%
%make_mat_name_function.FunctionArgs.CurFrame.FunctionInstance='GetPreviousFra
%meNr';
%make_mat_name_function.FunctionArgs.CurFrame.OutputArg='Sum';

arg_1=input_args.Number1.Value;
arg_2=input_args.Number2.Value;
output_args.Sum=(arg_1+arg_2);

%end addFunction
end
