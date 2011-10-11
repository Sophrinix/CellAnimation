function populateInputStringsListbox(handles)
%update the  

module_struct=handles.ModuleStruct;
module_path=[module_struct.ModuleName '.m'];
input_arguments=getInputArgs(module_path);
static_params=cellfun(@(x) x{1},module_struct.StaticParameters,'UniformOutput',false);
output_params=cellfun(@(x) x{1},module_struct.OutputArgs,'UniformOutput',false);
input_strings={};

for i=1:length(input_arguments)
    cur_arg=input_arguments{i};
    arg_params=[];
    %check if any static params match
    match_idx=strcmp(cur_arg,static_params);
    if (max(match_idx)==1)
        arg_params.Static=static_params(match_idx);
        static_params(match_idx)=[];
    end
    %check if any output params match
    match_idx=strcmp(cur_arg,output_params);
    if (max(match_idx)==1)
        arg_params.Output=output_params(match_idx);
        output_params(match_idx)=[];
    end
    input_strings=[input_strings formatInputStrings(cur_arg,arg_params)];
end

set(handles.listboxInputArgumens,'String',input_strings);

%end populateInputStringsListbox
end

function input_strings=formatInputStrings(input_arg, arg_params)
%extract and format static parameter for display

if isempty(arg_params)
    input_strings{1}=['<html><font color="red">' input_arg '</font></html>'];
    return;
else
    input_strings{1}=input_arg;    
end

field_names=fieldnames(arg_params);
if (max(strcmp('Output',field_names)==1))
    output_params=arg_params.Output;
    for i=2:(1+length(output_params))
        input_strings{i}=['<html><i>&nbsp;Output' num2str(i-1) '</i></html>'];        
    end
end

ls=length(input_strings);
if (max(strcmp('Static',field_names)==1))
    static_params=arg_params.Static;    
    for i=(ls+1):(ls+length(static_params))
        input_strings{i}=['<html><i>&nbsp;Value' num2str(i-ls) '</i></html>'];
    end
end

%end formatInputStrings
end