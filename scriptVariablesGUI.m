function varargout = scriptVariablesGUI(varargin)
% SCRIPTVARIABLESGUI M-file for scriptVariablesGUI.fig
%      SCRIPTVARIABLESGUI, by itself, creates a new SCRIPTVARIABLESGUI or raises the existing
%      singleton*.
%
%      H = SCRIPTVARIABLESGUI returns the handle to a new SCRIPTVARIABLESGUI or the handle to
%      the existing singleton*.
%
%      SCRIPTVARIABLESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCRIPTVARIABLESGUI.M with the given input arguments.
%
%      SCRIPTVARIABLESGUI('Property','Value',...) creates a new SCRIPTVARIABLESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scriptVariablesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scriptVariablesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scriptVariablesGUI

% Last Modified by GUIDE v2.5 19-Sep-2011 22:24:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scriptVariablesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @scriptVariablesGUI_OutputFcn, ...
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


% --- Executes just before scriptVariablesGUI is made visible.
function scriptVariablesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scriptVariablesGUI (see VARARGIN)

% Choose default command line output for scriptVariablesGUI
handles.output = hObject;
handles.OK=false;
handles.PrevSelectionIdx=1;
mt_idx=find(strcmp(varargin, 'ScriptVariables'))+1;
script_vars=varargin{mt_idx};
handles.ScriptVariables=script_vars;
%show the script variables names
if ~isempty(script_vars)
    var_names=cellfun(@(x) x{1}, script_vars,'UniformOutput',false);
    set(handles.listboxScriptVars,'String',var_names);
    %show the value of the first variable
    var1=script_vars{1};
    var_val=var1{2};
    set(handles.editScriptVarVal,'String',var_val);
else
    set(handles.listboxScriptVars,'String','');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scriptVariablesGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scriptVariablesGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1}=handles.OK;
varargout{2}=handles.ScriptVariables;
delete(hObject);


% --- Executes on selection change in listboxScriptVars.
function listboxScriptVars_Callback(hObject, eventdata, handles)
% hObject    handle to listboxScriptVars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxScriptVars contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxScriptVars
%first update the value of the previously selected variable
prev_idx=handles.PrevSelectionIdx;
script_vars=handles.ScriptVariables;
if isempty(script_vars)
    return;
end
script_vars{prev_idx}{2}=get(handles.editScriptVarVal,'String');
var_idx=get(hObject,'Value');
cur_var=script_vars{var_idx};
%update the edit box with the value of the current variable
set(handles.editScriptVarVal,'String',cur_var{2});
handles.PrevSelectionIdx=var_idx;
handles.ScriptVariables=script_vars;
guidata(handles.figure1,handles);


% --- Executes during object creation, after setting all properties.
function listboxScriptVars_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxScriptVars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editScriptVarVal_Callback(hObject, eventdata, handles)
% hObject    handle to editScriptVarVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editScriptVarVal as text
%        str2double(get(hObject,'String')) returns contents of
%        editScriptVarVal as a double


% --- Executes during object creation, after setting all properties.
function editScriptVarVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editScriptVarVal (see GCBO)
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
%update the value of the current variable
cur_idx=get(handles.listboxScriptVars,'Value');
script_vars=handles.ScriptVariables;
script_vars{cur_idx}{2}=get(handles.editScriptVarVal,'String');
handles.ScriptVariables=script_vars;
guidata(handles.figure1,handles);
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonAdd.
function pushbuttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
var_name=inputdlg('Name','Enter variable name',1,{''},'on');
if isempty(var_name)
    return;
end
var_val=get(handles.editScriptVarVal,'String');
new_var={var_name{1},var_val};
script_vars=handles.ScriptVariables;
script_vars=[script_vars {new_var}];
var_names=cellfun(@(x) x{1}, script_vars,'UniformOutput',false);
set(handles.listboxScriptVars,'String',var_names);
set(handles.listboxScriptVars,'Value',length(script_vars));
handles.PrevSelectionIdx=length(script_vars);
handles.ScriptVariables=script_vars;
guidata(handles.figure1,handles);


% --- Executes on button press in pushbuttonDelete.
function pushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%delete the current script variable
var_idx=get(handles.listboxScriptVars,'Value');
script_vars=handles.ScriptVariables;
script_vars(var_idx)=[];
handles.ScriptVariables=script_vars;
if isempty(script_vars)
    return;
end
%update the variables list
var_names=cellfun(@(x) x{1}, script_vars,'UniformOutput',false);
set(handles.listboxScriptVars,'String',var_names);
if (var_idx>1)
    set(handles.listboxScriptVars,'Value',(var_idx-1));
    %update the var value
    set(handles.editScriptVarVal,'String',script_vars{var_idx-1}{2});
else
    %update the var value
    set(handles.editScriptVarVal,'String',script_vars{1}{2});
end

guidata(handles.figure1,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);


