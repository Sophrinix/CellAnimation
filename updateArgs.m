function []=updateArgs(instance_name,function_struct,update_type)
%CellAnimation core function
%update input parameters of dependent functions using either input or
%output parameters of function
global dependencies_list;
global dependencies_index;

cur_idx=dependencies_index.get(instance_name);
dependency_item=dependencies_list{cur_idx};
dependent_functions=dependency_item.DependentFunctions;
for i=1:size(dependent_functions,1)
    cur_function=dependent_functions{i};
    function_instance=cur_function.InstanceName;
    function_idx=dependencies_index.get(function_instance);
    dependent_args=cur_function.DependentArgs;
    for j=1:size(dependent_args,1)
        args_struct=dependent_args{j};
        arg_name=args_struct.ArgumentName;        
        switch(update_type)
            case('input')
                if (args_struct.Type==2)
                    input_arg_name=args_struct.InputArg;
                    if (args_struct.DependencyType==1)
                        dependencies_list{function_idx}.FunctionArgs.(arg_name).Value=function_struct.(input_arg_name).Value;
                    elseif (args_struct.DependencyType==2)
                        dependencies_list{function_idx}.KeepValues.(arg_name).Value=function_struct.(input_arg_name).Value;
                    end
                end
            case('output')
                if (args_struct.Type==1)
                    output_arg_name=args_struct.OutputArg;
                    if (args_struct.DependencyType==1)
                        dependencies_list{function_idx}.FunctionArgs.(arg_name).Value=function_struct.(output_arg_name);
                    elseif (args_struct.DependencyType==2)
                        dependencies_list{function_idx}.KeepValues.(arg_name).Value=function_struct.(output_arg_name);
                    end
                end        
        end        
    end    
end

%end updateArgs
end