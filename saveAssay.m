function saveAssay(handles,file_name,path)
%write the assay to file
if (file_name==0)
    return;
end

function_name=file_name(1:(end-2));

assay_text=['function []=' function_name '()' 10 addAssayDescription(handles) 10 'global functions_list;' 10 'functions_list=[];' 10];

assay_text=[assay_text addScriptVars(handles)];

assay_text=[assay_text addChainVars(handles)];

assay_end=[10 'global dependencies_list;' 10 'global dependencies_index;' 10 'dependencies_list={};' 10 ];
assay_end=[assay_end 'dependencies_index=java.util.Hashtable;' 10 'makeDependencies([]);' 10 'runFunctions();' 10 'end'];

modules_list=traceArgs(handles);

for i=1:length(modules_list)
    assay_text=[assay_text buildModuleText(modules_list{i})];
end

assay_text=[assay_text assay_end];
fid=fopen([path '/' file_name],'wt');
fwrite(fid,assay_text);
fclose(fid);
handles.CurrentAssay=file_name;
handles.AssayPath=path;
guidata(handles.figure1,handles);
set(handles.figure1,'Name',['CellAnimation Assay Editor - ' file_name(1:(end-2))]);

%end saveAssay
end

function description_text=addAssayDescription(handles)
%build the comment section at the top of the assay

assay_description=handles.AssayDescription;
description_text='';

for i=1:size(assay_description)
    cur_line=strtrim(assay_description(i,:));
    ws_idx=regexp(cur_line,'(\s)','start');
    ws_nr=length(ws_idx);
    prev_pos_idx=1;
    if ws_nr
        for j=1:14:ws_nr
            if (j+14)>ws_nr
                pos_idx=length(cur_line);
            else
                pos_idx=ws_idx(j+14);
            end
            description_text=[description_text '%' cur_line(prev_pos_idx:pos_idx) 10];
            prev_pos_idx=pos_idx+1;
        end
    else
        description_text=[description_text '%' cur_line 10];
    end        
end

%end addAssayDescription
end

function chains_text=addChainVars(handles)
%add the chain variables for all the modules in this assay

chains_text=[10];
modules_list=handles.ModulesList;
parents_idx=cellfun(@(x) x.IsParent, modules_list);
parents_list=modules_list(parents_idx);
for i=1:length(parents_list)
    cur_parent=parents_list{i};
    parent_chains=cur_parent.Chains;
    for j=1:length(parent_chains)
        chains_text=[chains_text parent_chains{j} '=[];' 10];        
    end
end
chains_text=[chains_text 10];

%end addChainVars
end


function module_text=buildModuleText(module_struct)

%add the instance name
module_text=[];
instance_var=lower(module_struct.InstanceName);
module_text=[module_text instance_var '.InstanceName=''' module_struct.InstanceName ''';' 10];
module_text=[module_text instance_var '.FunctionHandle=@' module_struct.ModuleName ';' 10];
module_text=[module_text addStaticArgs(module_struct,instance_var)];
[output_args_text args_count]=addOutputArgs(module_struct,instance_var);
module_text=[module_text output_args_text];
module_text=[module_text addInputArgs(module_struct,instance_var,args_count)];
if module_struct.IsParent
    %add any output arguments that are being saved
    module_text=[module_text addKeepOutputArgs(module_struct,instance_var)];
    switch module_struct.ModuleName
        case {'forLoop','whileLoop'}
            module_text=[module_text instance_var '.' module_struct.ChainVars{1} '=' module_struct.Chains{1} ';' 10];
        case {'if_statement'}
            module_text=[module_text instance_var '.' module_struct.ChainVars{1} '=' module_struct.Chains{1} ';' 10];
            if (length(module_struct.ChainVars)>1)
                module_text=[module_text instance_var '.' module_struct.ChainVars{2} '=' module_struct.Chains{2} ';' 10];
            else
                module_text=[module_text instance_var '.ElseFunctions=[];' 10];
            end
    end
end
module_text=[module_text module_struct.ChainName '=addToFunctionChain(' module_struct.ChainName ',' instance_var ');' 10];
module_text=[module_text 10];

%end buildModuleText
end

function args_text=addStaticArgs(module_struct,instance_var)
%write the module's static arguments 
%keep track if an argument appears more than once and write out each to text
args_count=java.util.HashMap;
static_args=module_struct.StaticParameters;
args_text=[];
for i=1:length(static_args)
    cur_arg=static_args{i};
    cur_count=args_count.get(cur_arg{1});
    if isempty(cur_count)
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.Value=' cur_arg{2} ';' 10];
        args_count.put(cur_arg{1},2);
    else
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.Value' num2str(cur_count) '=' cur_arg{2} ';' 10];
        args_count.put(cur_arg{1},cur_count+1);
    end
end

%end addStaticArgs
end


function [args_text args_count]=addOutputArgs(module_struct,instance_var)
%write the module's output arguments 
%keep track if an argument appears more than once and write out each to
%text
args_count=java.util.HashMap;
args_text=[];
output_args=module_struct.OutputArgs;
for i=1:length(output_args)
    cur_arg=output_args{i};
    cur_count=args_count.get(cur_arg{1});
    if isempty(cur_count)
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.FunctionInstance=''' cur_arg{2} ''';' 10];
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.OutputArg=' cur_arg{3} ';' 10];
        args_count.put(cur_arg{1},2);
    else
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.FunctionInstance' num2str(cur_count) '=''' cur_arg{2} ''';' 10];
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.OutputArg' num2str(cur_count) '=' cur_arg{3} ';' 10];
    end
end

%end addOutputArgs
end

function args_text=addKeepOutputArgs(module_struct,instance_var)
%write the module's keepoutput arguments 
%keep track if an argument appears more than once and write out each to text
args_count=java.util.HashMap;
args_text=[];
output_args=module_struct.KeepOutputArgs;
for i=1:length(output_args)
    cur_arg=output_args{i};
    cur_count=args_count.get(cur_arg{1});
    if isempty(cur_count)
        args_text=[args_text instance_var '.KeepValues.' cur_arg{1} '.FunctionInstance=''' cur_arg{2} ''';' 10];
        args_text=[args_text instance_var '.KeepValues.' cur_arg{1} '.OutputArg=' cur_arg{3} ';' 10];
        args_count.put(cur_arg{1},2);
    else
        args_text=[args_text instance_var '.KeepValues.' cur_arg{1} '.FunctionInstance' num2str(cur_count) '=''' cur_arg{2} ''';' 10];
        args_text=[args_text instance_var '.KeepValues.' cur_arg{1} '.OutputArg' num2str(cur_count) '=' cur_arg{3} ';' 10];
    end
end

%end addKeepOutputArgs
end


function args_text=addInputArgs(module_struct,instance_var,args_count)
%write the module's input arguments 
%keep track if an argument appears more than once and write out each to
%text
args_text=[];
input_args=module_struct.InputArgs;
for i=1:length(input_args)
    cur_arg=input_args{i};
    cur_count=args_count.get(cur_arg{1});
    if isempty(cur_count)
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.FunctionInstance=''' cur_arg{2} ''';' 10];
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.InputArg=' cur_arg{3} ';' 10];
        args_count.put(cur_arg{1},2);
    else
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.FunctionInstance' num2str(cur_count) '=''' cur_arg{2} ''';' 10];
        args_text=[args_text instance_var '.FunctionArgs.' cur_arg{1} '.InputArg' num2str(cur_count) '=' cur_arg{3} ';' 10];
    end
end

%end addInputArgs
end


function modules_list=traceArgs(handles)
%add input args and keepvalues as necessary to connect a destination
%module to its source module (the module needing an input argument to the
%provider of that input argument)

modules_list=handles.ModulesList;
modules_map=handles.ModulesMap;
for i=1:length(modules_list)
    cur_module=modules_list{i};
    original_args=cur_module.OutputArgs;
    new_args={};
    for j=1:length(original_args)
        cur_arg=original_args{j};
        output_idx=modules_map.get(cur_arg{2});
        output_struct=modules_list{output_idx};
        if (strcmp(cur_module.ChainName,output_struct.ChainName)||strcmp(cur_module.Parent,output_struct.InstanceName)||...
                strcmp(cur_module.InstanceName,output_struct.Parent)||strcmp(cur_module.Parent,output_struct.Parent))
            new_args=[new_args {cur_arg}];
        else
            %replace the output arg with an input arg from a
            %control module. also add all the appropriate connections from
            %source module to destination module
            %first erase the current argument as it will be replaced with a properly
            %connected one
            cur_arg_idx=cellfun(@(x) strcmp(x{1},cur_arg{1})&&strcmp(x{2},cur_arg{2})&&strcmp(x{3},cur_arg{3}), cur_module.OutputArgs);
            cur_module.OutputArgs(cur_arg_idx)=[];
            modules_list{i}=cur_module;
            modules_list=getArgument(cur_arg,cur_module,output_struct,modules_list,modules_map);
            cur_module=modules_list{i};
        end
    end
%     cur_module.OutputArgs=new_args;
    modules_list{i}=cur_module;
end

%end extractInputArgs
end

function new_list=getArgument(cur_arg,cur_module,output_module,modules_list,modules_map)
%find the path to the argument and add input arguments or keepvalues at each point
%get the parents for the cur_module
new_list=modules_list;
%create a unique argument name
output_name=cur_arg{3};
output_name=output_name(2:(end-1));
arg_name=[output_module.InstanceName '_' output_name];
dest_modules=getModuleInstances(cur_module,new_list,modules_map);
source_modules=getModuleInstances(output_module,new_list,modules_map);
[dest_chains dest_chains_modules]=getChainsList(cur_module,new_list,modules_map);
[source_chains source_chains_modules]=getChainsList(output_module,new_list,modules_map);
dest_chains_modules(end)=dest_chains(end);
source_chains_modules(end)=source_chains(end);
   
%the output module may be a parent of one of the cur_module's parents
if isempty(cur_module.Parent)
    common_module=[];
    common_chain={'functions_list'};
    highest_dest=cur_module;
else
    %get the common module
    common_idx=ismember(dest_modules,source_modules);
    common_module_idx=find(common_idx==1,1,'first');
    if isempty(common_module_idx)
        common_module=[];
    else
        common_module=dest_modules(common_module_idx);        
    end
    %get the common module
    common_idx=ismember(dest_chains_modules,source_chains_modules);
    common_chain_idx=find(common_idx==1,1,'first');
    if isempty(common_chain_idx)
        common_chain=[];
    else
        common_chain=dest_chains_modules(common_chain_idx);        
    end
    %move up from the cur_module to second-highest chain setting up input
    %arguments
    cur_parent=cur_module;
    parent_idx=modules_map.get(cur_parent.InstanceName);
    i=1;
    while(~strcmp(cur_parent.InstanceName,common_module)&&~strcmp(cur_parent.Parent,common_chain))
        if isempty(cur_parent.Parent)
            break;
        end
        input_args=cur_parent.InputArgs;
        if (i==1)
            %for the actual destination we must use the proper argument
            %name
            new_arg={{cur_arg{1} cur_parent.Parent ['''' arg_name '''']}};
        else            
            %any intermediary control modules we use the unique name we
            %made up
            new_arg={{arg_name cur_parent.Parent ['''' arg_name '''']}};            
        end
        existing_arg_names=cellfun(@(x) x{3}, input_args,'UniformOutput',false);
        if (isempty(input_args)||(max(strcmp(existing_arg_names,['''' arg_name '''']))==0))
            %if the argument doesn't already exists add it
            cur_parent.InputArgs=[input_args new_arg];
            new_list{parent_idx}=cur_parent;
        end
        parent_idx=modules_map.get(cur_parent.Parent);
        cur_parent=new_list{parent_idx};
        i=i+1;
    end
    %get the highest level destination    
    highest_dest=cur_parent;
end

%move up to first common parent from output_module and make sure the
%output value is saved
cur_child=output_module;
i=1;
while(~strcmp(cur_child.Parent,common_module)&&~strcmp(cur_child.InstanceName,common_chain))
    if isempty(cur_child.Parent)
        break;
    end
    cur_parent_idx=modules_map.get(cur_child.Parent);
    cur_parent=new_list{cur_parent_idx};
    if (i==1)
        new_val={{arg_name cur_child.InstanceName cur_arg{3}}};
    else
        new_val={{arg_name cur_child.InstanceName ['''' arg_name '''']}};
    end
    keep_vals=cur_parent.KeepOutputArgs;
    if isempty(keep_vals)
        %this keepval doesn't exist so add it
        cur_parent.KeepOutputArgs=[keep_vals new_val];
        new_list{cur_parent_idx}=cur_parent;
    else
        output_idx=cellfun(@(x) strcmp(x{3},new_val{1}{3})&strcmp(x{2},new_val{1}{2}), keep_vals);
        if (max(output_idx)==0)
            %this keepval doesn't exist so add it
            cur_parent.KeepOutputArgs=[keep_vals new_val];
            new_list{cur_parent_idx}=cur_parent;
        end
    end
    cur_child=cur_parent;
    i=i+1;
end

%get the highest-level source
highest_source=cur_child;
highest_dest_idx=modules_map.get(highest_dest.InstanceName);
highest_dest=new_list{highest_dest_idx};    


%finally add an output arg connecting the highest level destination with the highest level source
if strcmp(highest_dest.InstanceName,cur_module.InstanceName)
    new_arg={{cur_arg{1} highest_source.InstanceName ['''' arg_name '''']}};
elseif strcmp(highest_source.InstanceName,output_module.InstanceName)
    new_arg={{arg_name highest_source.InstanceName cur_arg{3}}};
else
    new_arg={{arg_name highest_source.InstanceName ['''' arg_name '''']}};
end
output_args=highest_dest.OutputArgs;
if isempty(output_args)
    %this output arg doesn't exist so add it
    highest_dest.OutputArgs=[output_args new_arg];
else
    output_idx=cellfun(@(x) strcmp(x{3},new_arg{1}{3})&strcmp(x{2},new_arg{1}{2}), output_args);
    if (max(output_idx)==0)
        %this output arg doesn't exist so add it
        highest_dest.OutputArgs=[output_args new_arg];
    end
end
new_list{highest_dest_idx}=highest_dest;


%end getArgument
end

function module_instances=getModuleInstances(cur_module,modules_list,modules_map)

module_instances={cur_module.InstanceName};
while ~isempty(cur_module.Parent)
    module_instances=[module_instances {cur_module.Parent}];
    cur_parent_idx=modules_map.get(cur_module.Parent);
    cur_module=modules_list{cur_parent_idx};   
end

%end getModuleChain
end

function [chains_list chains_modules]=getChainsList(cur_module,modules_list,modules_map)

chains_list={};
chains_modules={};
if cur_module.IsParent
    chains=cur_module.Chains;
    for i=1:length(chains)
        chains_list=[chains_list chains(i)];
        chains_modules=[chains_modules {cur_module.InstanceName}];
    end
end
chains_list=[chains_list {cur_module.ChainName}];
chains_modules=[chains_modules {cur_module.Parent}];
while ~isempty(cur_module.Parent)
    cur_parent_idx=modules_map.get(cur_module.Parent);
    cur_module=modules_list{cur_parent_idx};
    chains_list=[chains_list {cur_module.ChainName}];
    chains_modules=[chains_modules {cur_module.Parent}];
end

%end getModuleChain
end