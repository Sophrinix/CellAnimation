function removeProvider(handles)
%remove the selected provider
assay_list=get(handles.listboxInputArgumens,'String');
selection_idx=get(handles.listboxInputArgumens,'Value');
selection_text=assay_list{selection_idx};
if (length(selection_text)<9)||~strcmp(selection_text(1:9),'<html><i>')
    warndlg('You need to select a provider name (in italics)');
    return;
end
module_struct=handles.ModuleStruct;
arg_text=selection_text;
orig_idx=selection_idx;
arg_type=regexp(arg_text,'<i>&nbsp;([a-zA-Z]*)(\d*)</i>','tokens','once');
selection_idx=selection_idx-1;
input_name=assay_list{selection_idx};
while (length(input_name)>9)&&strcmp(input_name(1:9),'<html><i>')
    selection_idx=selection_idx-1;
    input_name=assay_list{selection_idx};
end
if strcmp(arg_type{1},'Output')    
    arg_idx=str2double(arg_type{2});
    match_idx=cellfun(@(x) strcmp(x{1},input_name),module_struct.OutputArgs);
    match_idx=find(match_idx);    
    module_struct.OutputArgs(match_idx(arg_idx))=[];
else
    arg_idx=str2double(arg_type{2});
    match_idx=cellfun(@(x) strcmp(x{1},input_name),module_struct.StaticParameters);
    match_idx=find(match_idx);        
    module_struct.StaticParameters(match_idx(arg_idx))=[];
end
if isempty(module_struct.OutputArgs)&&isempty(module_struct.StaticParameters)
    %set the argument text in red to warn there's no provider
    assay_list{selection_idx}=['<html><font color="red">' assay_list{selection_idx} '</font></html>'];
end
if (orig_idx==length(assay_list))
    set(handles.listboxInputArgumens,'Value',orig_idx-1);
end
assay_list(orig_idx)=[];
%reduce the numbers on the remaining providers
switch(arg_type{1})
    case 'Output'
        output_args=module_struct.OutputArgs;
        if ~isempty(output_args)            
            match_idx=cellfun(@(x) strcmp(x{1},input_name),output_args);
            cur_args=output_args(match_idx);
            if ~isempty(cur_args)
                for i=arg_idx:length(cur_args)
                    assay_list{selection_idx+i}=['<html><i>&nbsp;Output' num2str(i) '</i></html>'];
                end
            end
        end
    case 'Value'
        static_args=module_struct.StaticParameters;
        if ~isempty(static_args)
            match_idx=cellfun(@(x) strcmp(x{1},input_name),static_args);
            cur_args=static_args(match_idx);
            if ~isempty(cur_args)
                match_idx=cellfun(@(x) strcmp(x{1},input_name),module_struct.OutputArgs);                
                output_args_len=sum(match_idx);
                for i=arg_idx:length(cur_args)
                    assay_list{selection_idx+output_args_len+i}=['<html><i>&nbsp;Value' num2str(i) '</i></html>'];
                end
            end
        end
end
set(handles.listboxInputArgumens,'String',assay_list);
handles.ModuleStruct=module_struct;
handles.Erased=true;
guidata(handles.figure1,handles);
inputArgumentsSelChange(handles);

%removeProvider
end