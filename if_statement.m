function [output_args]=if_statement(function_struct)

%propagate all the args to subfunctions
updateArgs(function_struct.InstanceName,function_struct.FunctionArgs,'input');
test_function_instance=function_struct.TestFunction.InstanceName;
test_output=callFunction(test_function_instance,false);
input_args=function_struct.FunctionArgs;
if(test_output.(input_args.TestResult.OutputArg))
    if_functions=function_struct.IfFunctions;
else
    if_functions=function_struct.ElseFunctions;
end

for i=1:size(if_functions,1)
    if_function_instance_name=if_functions{i}.InstanceName;
    callFunction(if_function_instance_name,false);
end

output_args=makeOutputStruct(function_struct);

%end if_statement
end