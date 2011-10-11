function aeMenuOpenAssay(hObject, eventdata, handles)

[dlg_ok, selected_assay]=openAssayGUI();
if (~dlg_ok)
    return;
end

handles.CurrentAssay=selected_assay;
handles.AssayPath=pwd;
handles.AssayDescription=getModuleDescription(selected_assay);
%read the script variables
handles.ScriptVariables=getScriptVariables(selected_assay);
[modules_list modules_map]=buildModulesList(selected_assay);
new_modules_list=cellfun(@(x) traceModuleArgs(x,modules_list,modules_map), modules_list,'UniformOutput',false);
handles.ModulesList=new_modules_list;
handles.ModulesMap=modules_map;
guidata(hObject,handles);
%get level 1 modules
level1_idx=cellfun(@(x) x.Level==1,new_modules_list);
modules_list=new_modules_list(level1_idx);
module_strings=formatModuleStrings(modules_list);
set(handles.listboxCurrentAssay,'String',module_strings);
set(handles.listboxCurrentAssay,'Value',1);
set(handles.figure1,'Name',['CellAnimation Assay Editor - ' selected_assay(1:(end-2))]);

%end aeMenuOpenAssay
end

function [modules_list modules_map]=buildModulesList(selected_assay)
%build a list of structures containing all the modules in sequential order
%read the assay text
file_text=fileread(selected_assay);
%remove the comments
file_text=regexp(file_text,'\n\r\%[^\n\r]*[\n\r]*','split');
file_text=strcat(file_text{:});

%get the names of every module instance and their corresponding function
%chain
module_tokens=regexp(file_text,'addToFunctionChain\(\s*(\w+),\s*(\w+)\s*\)','tokens');
chains_list=cellfun(@(x) x{1},module_tokens,'UniformOutput',false);
chains_list=unique(chains_list);
modules_nr=length(module_tokens);
modules_list=cell(modules_nr,1);
main_chain='functions_list';
prev_chain=main_chain; %main chain is called functions_list
chains_map=java.util.HashMap;
parents_map=java.util.HashMap;
modules_map=java.util.HashMap;
cur_level=1;
parent_instance='';
chains_map.put(prev_chain,cur_level);
parents_map.put(prev_chain,parent_instance);

for i=1:length(module_tokens)
    cur_tokens=module_tokens{i};
    cur_chain=cur_tokens{1};
    module_var=cur_tokens{2};
    if ~strcmp(prev_chain,cur_chain)
        prev_chain=cur_chain;
        cur_level=chains_map.get(cur_chain);        
        if isempty(cur_level)
            cur_level=getChainLevel(file_text,cur_chain,main_chain);            
            %get the parent module of the current chain
            parent_var=regexp(file_text,['(\w+)\.\w+=\s*' cur_chain],'once','tokens');
            parent_instance=regexp(file_text,['[;\n\r]' parent_var{1} '.InstanceName=.(\w*).;'],'once','tokens');
            parent_instance=parent_instance{1};
            chains_map.put(cur_chain,cur_level);
            parents_map.put(cur_chain,parent_instance);
        else
            parent_instance=parents_map.get(cur_chain);
        end
    end
    modules_list{i}=extractModule(file_text,module_var,parent_instance,cur_level,cur_chain,modules_list,chains_list);
    modules_map.put(modules_list{i}.InstanceName,i);
end

%end buildModulesList
    end

function ml=getChainLevel(file_text,sub_chain,main_chain)
%get the level of the current chain
cur_chain=sub_chain;
ml=1;
while ~strcmp(cur_chain,main_chain)
    ml=ml+1;
    %get the parent module of the current chain
    parent_var=regexp(file_text,['(\w+)\.\w+=\s*' cur_chain],'once','tokens');
    %get the chain of the parent module
    cur_chain=regexp(file_text,['addToFunctionChain\(\s*(\w*)\s*,\s*' parent_var{1} '\s*\)'],'once','tokens');
    cur_chain=cur_chain{1};
end

%end getChainLevel
end

function module_struct=extractModule(file_text,module_var,parent_instance,module_level,module_chain,modules_list,chains)
%extract module struct from module assay
%build module structure
module_struct.VarName=module_var;
module_struct.Parent=parent_instance;
module_struct.Level=module_level;
module_struct.ChainName=module_chain;
%get the module section
module_lines=regexp(file_text,['\<' module_var '[^\n\r]*[\n\r]*;'],'match');
module_text=strcat(module_lines{:});
%find the instance name 
search_pattern=[module_var '.InstanceName=.(\w*).;'];
instance_name=regexp(module_text,search_pattern,'once','tokens');
module_struct.InstanceName=instance_name{1};
%find the module name
search_pattern=[module_var '.FunctionHandle *= *@(\w*);'];
module_name=regexp(module_text,search_pattern,'once','tokens');
module_struct.ModuleName=module_name{1};
%is this module a control module
is_parent_idx=strcmp(module_struct.ModuleName,{'if_statement','whileLoop','forLoop'});
module_struct.IsParent=max(is_parent_idx);
if (module_struct.IsParent)
    %get the chains
    switch(module_struct.ModuleName)
        case {'forLoop','whileLoop'}
            module_struct.ChainVars={'LoopFunctions'};
            search_pattern=[module_var '.LoopFunctions=(\w*);'];
            chains=regexp(file_text,search_pattern,'tokens','once');
            module_struct.Chains=chains;
        case 'if_statement'
            module_struct.ChainVars={'ElseFunctions','IfFunctions'};
            search_pattern=[module_var '.ElseFunctions=(\w*);'];
            chains=regexp(file_text,search_pattern,'tokens','once');
            module_struct.Chains(1)=chains;
            search_pattern=[module_var '.IfFunctions=(\w*);'];
            chains=regexp(file_text,search_pattern,'tokens','once');
            module_struct.Chains(2)=chains;
    end        
else
    module_struct.Chains={};
    module_struct.ChainVars={};
end
%get the static args
search_pattern=[module_var '.FunctionArgs.(\w*).Value *= *([^;]+);'];
module_struct.StaticParameters=regexp(module_text,search_pattern,'tokens');
%get the output args
search_pattern=[module_var '.FunctionArgs.(\w*).FunctionInstance\d* *= *.(\w*).;' module_var '.FunctionArgs.\w*.OutputArg\d* *= *([^;]+);'];
module_struct.OutputArgs=regexp(module_text,search_pattern,'tokens');
%get the input args
search_pattern=[module_var '.FunctionArgs.(\w*).FunctionInstance\d* *= *.(\w*).;' module_var '.FunctionArgs.\w*.InputArg\d* *= *([^;]+);'];
module_struct.InputArgs=regexp(module_text,search_pattern,'tokens');
%get the output keep values
search_pattern=[module_var '.KeepValues.(\w*).FunctionInstance\d* *= *.(\w*).;' module_var '.KeepValues.\w*.OutputArg\d* *= *([^;]+);'];
module_struct.KeepOutputArgs=regexp(module_text,search_pattern,'tokens');

%end extractModule
end

function ip=isParent(module_struct,instance_name)
if isempty(module_struct)
    ip=false;
else
    ip=strcmp(module_struct.Parent,instance_name);
end
%end moduleHasParent
end

function arg_belongs=argBelongsToControlModule(arg_name,control_module)
%test if this argument belongs to a control
%module or if it's just being held for other modules
switch(control_module.ModuleName)
    case 'forLoop'
        internal_args={'EndLoop','IncrementLoop','StartLoop'};        
    case 'whileLoop'
        internal_args={'TestFunction'};
    case 'if_statement'
        internal_args={'TestVariable'};
end

arg_belongs=max(strcmp(internal_args,arg_name{1}));
%end
end

function new_struct=traceModuleArgs(module_struct, modules_list, modules_map)
%trace any arguments provided by a control module to the module that provide the actual
%output args
input_args=module_struct.InputArgs;
output_args=module_struct.OutputArgs;
new_output_args={};
static_args={};
for i=1:length(output_args)
    %most output args by control modules don't belong to them
    cur_arg=output_args{i};
    if (module_struct.IsParent&&(~argBelongsToControlModule(cur_arg,module_struct)))
        %this is an intermediary argument. it will be traced later from its
        %proper module
        continue;
    end    
    arg_idx=modules_map.get(cur_arg{2});
    arg_struct=modules_list{arg_idx};
    if (arg_struct.IsParent)
        arg_name=cur_arg{3};
        arg_name=arg_name(2:(end-1));
        if strcmp(arg_name,'LoopCounter')
            %only existing true output arg of a control module
            if strcmp(arg_struct.ModuleName,'forLoop')
                %and this is a for loop so true output - skip this one
                new_output_args=[new_output_args {cur_arg}];
                continue;
            end
        end
        new_output_args=[new_output_args traceOutputArg(cur_arg{1}, cur_arg, arg_struct, modules_list, modules_map)];
    else
        new_output_args=[new_output_args {cur_arg}];
    end
end

for i=1:length(input_args)
    cur_arg=input_args{i};
    if (module_struct.IsParent&&(~argBelongsToControlModule(cur_arg,module_struct)))
        %controle modules shouldn't modify arguments that don't really
        %belong to them
        continue;
    end
   [arg_structs arg_types]=traceInputArg(cur_arg, modules_list, modules_map);
   for j=1:length(arg_types)
       %replace the arg name with the original input name
       arg_structs{j}{1}=cur_arg{1};
       cur_type=arg_types{j};
       switch cur_type
           case 'output'
               new_output_args=[new_output_args arg_structs(j)];
           case 'static'
               static_args=[static_args arg_structs(j)];
       end
   end
end
module_struct.InputArgs={};
new_struct=module_struct;
new_struct.OutputArgs=new_output_args;
new_struct.StaticParameters=[module_struct.StaticParameters static_args];
%what output args to keep will be determined dynamically when the assay is
%saved
new_struct.KeepOutputArgs={};

%end traceModuleArgs
end

function output_args=traceOutputArg(arg_name, output_arg, arg_struct, modules_list, modules_map)
%trace an output module in a control module to its provider(s)
cur_arg=output_arg;
output_args={};
while arg_struct.IsParent
    new_args=arg_struct.KeepOutputArgs;
    new_arg_name=cur_arg{3};
    new_arg_name=new_arg_name(2:(end-1));
    new_arg_idx=cellfun(@(x) strcmp(x{1},new_arg_name),new_args);    
    cur_args=new_args(new_arg_idx);
    if (length(cur_args)>1)
        for i=1:length(cur_args)
            cur_arg=cur_args{i};
            cur_arg_idx=modules_map.get(cur_arg{2});
            arg_struct=modules_list{cur_arg_idx};
            output_args=[output_args traceOutputArg(arg_name, cur_arg, arg_struct, modules_list, modules_map)];            
        end
        return;
    else
        cur_arg=cur_args{1};
    end
    cur_arg_idx=modules_map.get(cur_arg{2});
    arg_struct=modules_list{cur_arg_idx};    
end

new_arg={{arg_name cur_arg{2} cur_arg{3}}};
output_args=[output_args new_arg];

%end traceOutputArg
end

function [arg_structs arg_types]=traceInputArg(input_arg, modules_list, modules_map)
%trace an input arg to the module(s) which provides the output value(s)
module_instance=input_arg{2};
module_idx=modules_map.get(module_instance);
module_struct=modules_list{module_idx};
module_name=module_struct.ModuleName;
%if the module is not a control module it is the module which provides the
%output value
switch module_name
    case {'forLoop','if_statement','whileLoop'}
        [arg_structs arg_types]=findArgStruct(input_arg, module_struct, modules_list, modules_map);        
    otherwise
        assert(false);
end
%end traceArg
end

function [arg_structs arg_types]=findArgStruct(input_arg, module_struct, modules_list, modules_map)
%find which structure holds the reference to this input argument could be
%multiple
input_struct=module_struct.InputArgs;
arg_name=input_arg{3};
arg_name=arg_name(2:(end-1));
arg_structs={};
arg_types={};
if (~isempty(input_struct))
    struct_names=cellfun(@(x) x{1},input_struct,'UniformOutput',false);
    arg_idx=strcmp(arg_name,struct_names);
    if (max(arg_idx)==1)
        %this struct is not where the values come from originally
        [arg_structs arg_types]=traceInputArg(input_struct{arg_idx}, modules_list, modules_map);        
    end
end

static_struct=module_struct.StaticParameters;
arg_name=input_arg{3};
arg_name=arg_name(2:(end-1));
if (~isempty(static_struct))
    struct_names=cellfun(@(x) x{1},static_struct,'UniformOutput',false);
    arg_idx=strcmp(arg_name,struct_names);
    if (max(arg_idx)==1)
        %this struct lists the values come from originally        
        static_args=static_struct(arg_idx);
        %change the input name to the name expected by the destination
        %module
        nr_matches=sum(arg_idx);
        for i=1:nr_matches
            cur_arg=static_args{i};
            arg_structs=[arg_structs; {{input_arg{1} cur_arg{2}}}];
            arg_types=[arg_types; {'static'}];
        end
    end
end

output_struct=module_struct.OutputArgs;
arg_name=input_arg{3};
arg_name=arg_name(2:(end-1));
if (~isempty(output_struct))
    struct_names=cellfun(@(x) x{1},output_struct,'UniformOutput',false);
    arg_idx=strcmp(arg_name,struct_names);
    if (max(arg_idx)==1)
        %this struct lists the values come from originally
        output_args=output_struct(arg_idx);
        %change the input name to the name expected by the destination
        %module
        nr_matches=sum(arg_idx);
        for i=1:nr_matches
            cur_arg=output_args{i};
            arg_structs=[arg_structs; {{input_arg{1} cur_arg{2} cur_arg{3}}}];
            arg_types=[arg_types; {'output'}];
        end        
    end
end

%end findArgStruct
end