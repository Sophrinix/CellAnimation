function output_args=whileLoop(function_struct)
%need to add break functionality
global dependencies_list;
global dependencies_index;

instance_name=function_struct.InstanceName;
cur_idx=dependencies_index.get(instance_name);

%propagate any input args needed by the loop functions from outside
updateArgs(instance_name,function_struct.FunctionArgs,'input');
test_function_instance=function_struct.TestFunction.InstanceName;
test_output=callFunction(test_function_instance,false);
input_args=function_struct.FunctionArgs;
loop_functions=function_struct.LoopFunctions;

while(test_output.(input_args.TestResult.OutputArg))
    for j=1:size(loop_functions,1)
        loop_function_instance_name=loop_functions{j}.InstanceName;
        callFunction(loop_function_instance_name,false);
    end
    dependency_item=dependencies_list{cur_idx};
    %propagate any updated input args to the loop functions
    updateArgs(instance_name,dependency_item.FunctionArgs,'input');
    output_args=makeOutputStruct(function_struct);
    updateArgs(instance_name,output_args,'output');
    test_output=callFunction(test_function_instance,false);
end


for i=1:size(loop_functions,1)
    loop_function_instance_name=loop_functions{i}.InstanceName;
    clearArgs(loop_function_instance_name);
end


%end while
end