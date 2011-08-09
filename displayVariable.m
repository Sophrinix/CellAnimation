function output_args=displayVariable(input_args)
%Usage
%This module is used to display a variable name and its value.
%
%Input Structure Members
%Variable – The variable whose value is to be displayed.
%VariableName – The variable name to be displayed along with the variable value.
%
%Output Structure Members
%None.
%
%Example
%
%display_trackstruct_function.InstanceName='DisplayTrackStruct';
%display_trackstruct_function.FunctionHandle=@displayVariable;
%display_trackstruct_function.FunctionArgs.Variable.Value=TrackStruct;
%display_trackstruct_function.FunctionArgs.VariableName.Value='TrackStruct';
%functions_list=addToFunctionChain(functions_list,display_trackstruct_function
%);

output_args=[];
disp(input_args.VariableName.Value);
disp(input_args.Variable.Value);

%end displayVariable
end
