function wrapFunction(handles)
%wrap a MATLAB function in a CellAnimation wrapper so it can be used as a
%module in a CA assay

%select the function
[file_name,path_name] = uigetfile('*.m','Select MATLAB function to wrap');
if ~file_name
    return;
end
%read the function text
fi=fopen([path_name file_name]);
tl=fgetl(fi);
while 1
    if (tl==-1)
        break;
    end
    %remove white spaces
    tl(isspace(tl))=[];
    if (length(tl)<1)||(tl(1)=='%')
        tl=fgetl(fi);
        continue;
    end
    if strfind(tl,'function')
        while strcmp(tl((end-2):end),'...')
            %line continues. read the entire statement
            cl=fgetl(fi);
            cl(isspace(cl))=[];
            tl=[tl(1:(end-3)) cl];
        end
        arg_names=regexp(tl,'\((.*)\)','tokens','once');
        if ~isempty(arg_names)
            break;
        end           
    end
    tl=fgetl(fi);
end
fclose(fi);
if (tl==-1)
    warndlg('Could not locate the function definition. Function wrapper was not created.');
    return;
end
%find the function name
fun_name=regexp(tl,'=([^\(=]*)\(','tokens','once');
if isempty(fun_name)
    fun_name=regexp(tl,'function(\w*)\(','tokens','once');    
    if isempty(fun_name)
        warndlg('Could not locate the function definition. Function wrapper was not created.');
        return;
    end
end
fun_text=['function output_args=' fun_name{1} '_Wrapper(input_args)' 10 ];
fun_text=[fun_text '%Wrapper module for the function ' fun_name{1} 10 10];
%get the input argument names
arg_list=regexp(arg_names{1},'([^,]*)','tokens');
fun_text=[fun_text addInputArgs(arg_list)];
output_args=regexp(tl,'\[([^\[\]]*)\]','tokens','once');
if isempty(output_args)
    %one or none output args
    output_args=regexp(tl,'function(\w*)=','tokens','once');
    args_list={output_args};
else
    args_list=regexp(output_args{1},'([^,]*)','tokens');    
end

%add call to the wrapped function replace the function name with the file
%name
name_start=strfind(tl,[fun_name{1} '(']);
fun_text=[fun_text tl(9:(name_start-1)) file_name(1:(end-2)) tl((name_start+length(fun_name{1})):end) ';' 10];

if isempty(output_args)
    fun_text=[fun_text 'output_args=[];' 10];
else    
    %populate the output args
    fun_text=[fun_text addOutputArgs(args_list)];
end

fun_text=[fun_text 10 'end'];

%write the wrapped function module to disk
[file_name path_name]=uiputfile('*.m','Save Module as:',[fun_name{1} '_Wrapper']);
fid=fopen([path_name file_name],'wt');
fwrite(fid,fun_text);
fclose(fid);

if strcmp(path_name(1:(end-1)),pwd)
    %module saved in the current path - add it to available modules list
    set(handles.listboxAvailableModules,'String',getModuleList());
end


%end wrapFunction
end

function args_text=addOutputArgs(args_list)
%create the wrapper text for the input arguments
args_text=[];
for i=1:length(args_list)
    cur_arg=args_list{i}{1};
    args_text=[args_text 'output_args.' cur_arg '=' cur_arg ';' 10];
end

%end addInputArgs
end

function args_text=addInputArgs(arg_list)
%create the wrapper text for the input arguments
args_text=[];
for i=1:length(arg_list)
    cur_arg=arg_list{i}{1};
    args_text=[args_text cur_arg '=input_args.' cur_arg '.Value;' 10];
end

%end addInputArgs
end