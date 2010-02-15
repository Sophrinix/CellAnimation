function output_args=forLoop(function_struct)
%need to add break functionality
global dependencies_list;
global dependencies_index;

instance_name=function_struct.InstanceName;
cur_idx=dependencies_index.get(instance_name);
loop_args=function_struct.FunctionArgs;
start_loop=loop_args.StartLoop.Value;
end_loop=loop_args.EndLoop.Value;
increment_loop=loop_args.IncrementLoop.Value;
loop_functions=function_struct.LoopFunctions;

for i=start_loop:increment_loop:end_loop
    dependency_item=dependencies_list{cur_idx};
    %propagate any updated input args to the loop functions
    updateArgs(instance_name,dependency_item.FunctionArgs,'input');
    %update the value of LoopCounter to dependent functions
    updateArg(instance_name,'output','LoopCounter',i);
    for j=1:size(loop_functions,1)
        loop_function_instance_name=loop_functions{j}.InstanceName;
        callFunction(loop_function_instance_name,false);
    end
    output_args=makeOutputStruct(function_struct);
    output_args.LoopCounter=i;
    updateArgs(instance_name,output_args,'output');
end


for i=1:size(loop_functions,1)
    loop_function_instance_name=loop_functions{j}.InstanceName;
    clearArgs(loop_function_instance_name);
end

%end forloop
end