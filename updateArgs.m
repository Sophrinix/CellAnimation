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
                        try
                            dependencies_list{function_idx}.FunctionArgs.(arg_name).Value=function_struct.(input_arg_name).Value;
                        catch ME
                            err_text=ME.message;
                            err_text=[err_text ' \n Function Instance: ' instance_name ' \n '];
                            err_text=[err_text 'Input arg name: ' output_arg_name ' \n '];
                            err_text=[err_text 'Dependent function arg name: ' arg_name ' \n '];
                            err_text=[err_text 'Dependent function name: ' function_instance ' \n '];
                            new_err.message=sprintf(err_text);
                            new_err.identifier=ME.identifier;
                            new_err.stack=ME.stack;
                            error(new_err);
                        end
                    elseif (args_struct.DependencyType==2)
                        try
                            dependencies_list{function_idx}.KeepValues.(arg_name).Value=function_struct.(input_arg_name).Value;
                        catch ME
                            err_text=ME.message;
                            err_text=[err_text ' \n Function Instance: ' instance_name ' \n '];
                            err_text=[err_text 'Input arg name: ' output_arg_name ' \n '];
                            err_text=[err_text 'Dependent function keepvalue name: ' arg_name ' \n '];
                            err_text=[err_text 'Dependent function name: ' function_instance ' \n '];
                            new_err.message=sprintf(err_text);
                            new_err.identifier=ME.identifier;
                            new_err.stack=ME.stack;
                            error(new_err);
                        end
                    end
                end
            case('output')
                if (args_struct.Type==1)
                    output_arg_name=args_struct.OutputArg;
                    if (args_struct.DependencyType==1)
                        try
                            dependencies_list{function_idx}.FunctionArgs.(arg_name).Value=function_struct.(output_arg_name);
                        catch ME
                            err_text=ME.message;
                            err_text=[err_text ' \n Function Instance: ' instance_name ' \n '];
                            err_text=[err_text 'Output arg name: ' output_arg_name ' \n '];                            
                            err_text=[err_text 'Dependent function arg name: ' arg_name ' \n '];
                            err_text=[err_text 'Dependent function name: ' function_instance ' \n '];
                            new_err.message=sprintf(err_text);
                            new_err.identifier=ME.identifier;
                            new_err.stack=ME.stack;
                            error(new_err);                            
                        end
                            
                    elseif (args_struct.DependencyType==2)
                        try
                            dependencies_list{function_idx}.KeepValues.(arg_name).Value=function_struct.(output_arg_name);
                        catch ME
                            err_text=ME.message;
                            err_text=[err_text ' \n Function Instance: ' instance_name ' \n '];
                            err_text=[err_text 'Output arg name: ' output_arg_name ' \n '];                            
                            err_text=[err_text 'Dependent function keepvalue name: ' arg_name ' \n '];
                            err_text=[err_text 'Dependent function name: ' function_instance ' \n '];
                            new_err.message=sprintf(err_text);
                            new_err.identifier=ME.identifier;
                            new_err.stack=ME.stack;
                            error(new_err);                            
                        end
                    end
                end        
        end        
    end    
end

%end updateArgs
end