function varargout = inputArgumentsGUI(varargin)
% INPUTARGUMENTSGUI M-file for inputArgumentsGUI.fig
%      INPUTARGUMENTSGUI, by itself, creates a new INPUTARGUMENTSGUI or raises the existing
%      singleton*.
%
%      H = INPUTARGUMENTSGUI returns the handle to a new INPUTARGUMENTSGUI or the handle to
%      the existing singleton*.
%
%      INPUTARGUMENTSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUTARGUMENTSGUI.M with the given input arguments.
%
%      INPUTARGUMENTSGUI('Property','Value',...) creates a new INPUTARGUMENTSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inputArgumentsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inputArgumentsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inputArgumentsGUI

% Last Modified by GUIDE v2.5 21-Sep-2011 21:01:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inputArgumentsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @inputArgumentsGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before inputArgumentsGUI is made visible.
function inputArgumentsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inputArgumentsGUI (see VARARGIN)

% Choose default command line output for inputArgumentsGUI

handles.output = hObject;
handles.OK=false;
mt_idx=find(strcmp(varargin, 'ModulesList'))+1;
handles.ModulesList=varargin{mt_idx};
mt_idx=find(strcmp(varargin, 'ModulesMap'))+1;
handles.ModulesMap=varargin{mt_idx};
ms_idx=find(strcmp(varargin, 'ModuleStruct'))+1;
handles.ModuleStruct=varargin{ms_idx};
handles.SelectionType='';
handles.SelectionValue='';
handles.Erased=false;
%make sure all the args that are filled refer to modules that still exist
handles.ModuleStruct=validateModuleArgs(handles);
module_struct=handles.ModuleStruct;
%update the window title
win_title=['Edit Module Parameters - ' module_struct.InstanceName ' - ' module_struct.ModuleName];
set(handles.figure1,'Name',win_title);
%show the module description
set(handles.editStatus,'String',getModuleDescription([module_struct.ModuleName '.m']));
%populate the dialog boxes
populateInputStringsListbox(handles);
populateModuleInstancesPopup(handles);
updateOutputArgPopup(handles);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes inputArgumentsGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = inputArgumentsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1}=handles.OK;
varargout{2}=handles.ModuleStruct;
delete(hObject);

% --- Executes on selection change in listboxInputArgumens.
function listboxInputArgumens_Callback(hObject, eventdata, handles)
% hObject    handle to listboxInputArgumens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxInputArgumens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxInputArgumens
inputArgumentsSelChange(handles);

% --- Executes during object creation, after setting all properties.
function listboxInputArgumens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxInputArgumens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupModuleInstance.
function popupModuleInstance_Callback(hObject, eventdata, handles)
% hObject    handle to popupModuleInstance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateOutputArgPopup(handles);
%get the current selection 
assay_list=get(handles.listboxInputArgumens,'String');
selection_idx=get(handles.listboxInputArgumens,'Value');
selection_text=assay_list{selection_idx};
%if an output argument is selected update its value
if (length(selection_text)>9)&&strcmp(selection_text(1:9),'<html><i>')
    %find the current argument
    i=1;
    arg_text=assay_list{selection_idx-i};
    while(~isempty(strfind(arg_text,'&nbsp')))
        i=i+1;
        arg_text=assay_list{selection_idx-i};        
    end
    module_struct=handles.ModuleStruct;
    arg_nr=regexp(selection_text,'([0-9])','tokens','once');
    arg_nr=str2double(arg_nr{1});
    %get the argument indices
    output_idx=find(cellfun(@(x) strcmp(x{1},arg_text), module_struct.OutputArgs));
    output_idx=output_idx(arg_nr);
    output_arg=module_struct.OutputArgs{output_idx};
    module_idx=get(hObject,'Value');
    popup_list=get(hObject,'String');
    module_instance=popup_list{module_idx};
    output_arg{2}=module_instance;
    arg_idx=get(handles.popupOutputArgument,'Value');
    arg_list=get(handles.popupOutputArgument,'String');
    arg_name=arg_list{arg_idx};
    output_arg{3}=['''' arg_name ''''];
    module_struct.OutputArgs(output_idx)={output_arg};
    handles.ModuleStruct=module_struct;
    guidata(handles.figure1,handles);
end

% Hints: contents = get(hObject,'String') returns popupModuleInstance contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupModuleInstance


% --- Executes during object creation, after setting all properties.
function popupModuleInstance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupModuleInstance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupOutputArgument.
function popupOutputArgument_Callback(hObject, eventdata, handles)
% hObject    handle to popupOutputArgument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupOutputArgument contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupOutputArgument
%get the current selection 
assay_list=get(handles.listboxInputArgumens,'String');
selection_idx=get(handles.listboxInputArgumens,'Value');
selection_text=assay_list{selection_idx};
%if an output argument is selected update its value
if (length(selection_text)>9)&&strcmp(selection_text(1:9),'<html><i>')
    %find the current argument
    i=1;
    arg_text=assay_list{selection_idx-i};
    while(~isempty(strfind(arg_text,'&nbsp')))
        i=i+1;
        arg_text=assay_list{selection_idx-i};        
    end
    module_struct=handles.ModuleStruct;
    arg_nr=regexp(selection_text,'([0-9])','tokens','once');
    arg_nr=str2double(arg_nr{1});
    %get the argument indices
    output_idx=find(cellfun(@(x) strcmp(x{1},arg_text), module_struct.OutputArgs));
    output_idx=output_idx(arg_nr);
    output_arg=module_struct.OutputArgs{output_idx};    
    module_idx=get(hObject,'Value');
    popup_list=get(hObject,'String');
    module_output=popup_list{module_idx};
    output_arg(3)={['''' module_output '''']};
    module_struct.OutputArgs(output_idx)={output_arg};
    handles.ModuleStruct=module_struct;
    guidata(handles.figure1,handles);
end


% --- Executes during object creation, after setting all properties.
function popupOutputArgument_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupOutputArgument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupInputArgument.
function popupInputArgument_Callback(hObject, eventdata, handles)
% hObject    handle to popupInputArgument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupInputArgument contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupInputArgument


% --- Executes during object creation, after setting all properties.
function popupInputArgument_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupInputArgument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editManualValue_Callback(hObject, eventdata, handles)
% hObject    handle to editManualValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editManualValue as text
%        str2double(get(hObject,'String')) returns contents of editManualValue as a double


% --- Executes during object creation, after setting all properties.
function editManualValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editManualValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OK=true;
if strcmp(handles.SelectionType,'ArgValue')&&~handles.Erased
    handles.ModuleStruct=updateArgValue(handles);
end
guidata(handles.figure1,handles);
uiresume(handles.figure1);

% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


function editStatus_Callback(hObject, eventdata, handles)
% hObject    handle to editStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of editStatus as text
%        str2double(get(hObject,'String')) returns contents of editStatus as a double


% --- Executes during object creation, after setting all properties.
function editStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddOptArg.
function pushbuttonAddOptArg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddOptArg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonRemOptArg.
function pushbuttonRemOptArg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemOptArg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonAddManualValue.
function pushbuttonAddManualValue_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddManualValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addManualValue(handles);


% --- Executes on button press in pushbuttonAddOutputArgument.
function pushbuttonAddOutputArgument_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddOutputArgument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addOutputArgument(handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);



% --- Executes on button press in pushbuttonRemove.
function pushbuttonRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeProvider(handles);

