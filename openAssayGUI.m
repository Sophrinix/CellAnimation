function varargout = openAssayGUI(varargin)
% OPENASSAYGUI M-file for openAssayGUI.fig
%      OPENASSAYGUI, by itself, creates a new OPENASSAYGUI or raises the existing
%      singleton*.
%
%      H = OPENASSAYGUI returns the handle to a new OPENASSAYGUI or the handle to
%      the existing singleton*.
%
%      OPENASSAYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPENASSAYGUI.M with the given input arguments.
%
%      OPENASSAYGUI('Property','Value',...) creates a new OPENASSAYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before openAssayGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to openAssayGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help openAssayGUI

% Last Modified by GUIDE v2.5 26-Jul-2011 12:18:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @openAssayGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @openAssayGUI_OutputFcn, ...
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


% --- Executes just before openAssayGUI is made visible.
function openAssayGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to openAssayGUI (see VARARGIN)

% Choose default command line output for openAssayGUI
handles.OK = false;
handles.SelectedAssay='';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes openAssayGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = openAssayGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.OK;
varargout{2}=handles.SelectedAssay;
delete(hObject);

% --- Executes on selection change in listboxModules.
function listboxModules_Callback(hObject, eventdata, handles)
% hObject    handle to listboxModules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxModules contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxModules
selection_type=get(handles.figure1,'SelectionType');
assay_list=get(hObject,'String');
selected_idx=get(hObject,'Value');
selected_assay=assay_list{selected_idx};
handles.SelectedAssay=selected_assay;
switch (selection_type)
    case 'normal'
        set(handles.editModuleDescription,'String',getModuleDescription(selected_assay));
    case 'open'
        handles.OK=true;
        guidata(handles.figure1,handles);
        uiresume(handles.figure1);
end

% --- Executes during object creation, after setting all properties.
function listboxModules_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxModules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
assay_list=getAssaysList();
set(hObject,'String',assay_list);




function editModuleDescription_Callback(hObject, eventdata, handles)
% hObject    handle to editModuleDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editModuleDescription as text
%        str2double(get(hObject,'String')) returns contents of editModuleDescription as a double


% --- Executes during object creation, after setting all properties.
function editModuleDescription_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editModuleDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
assay_list=getAssaysList();
set(hObject,'String',getModuleDescription(assay_list{1}));

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assay_list=get(handles.listboxModules,'String');
selected_idx=get(handles.listboxModules,'Value');
selected_assay=assay_list{selected_idx};
handles.SelectedAssay=selected_assay;
handles.OK=true;
guidata(handles.figure1,handles);
uiresume(handles.figure1);



% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);



