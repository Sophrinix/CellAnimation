function varargout = moduleParentGUI(varargin)
% MODULEPARENTGUI M-file for moduleParentGUI.fig
%      MODULEPARENTGUI, by itself, creates a new MODULEPARENTGUI or raises the existing
%      singleton*.
%
%      H = MODULEPARENTGUI returns the handle to a new MODULEPARENTGUI or the handle to
%      the existing singleton*.
%
%      MODULEPARENTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODULEPARENTGUI.M with the given input arguments.
%
%      MODULEPARENTGUI('Property','Value',...) creates a new MODULEPARENTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before moduleParentGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to moduleParentGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help moduleParentGUI

% Last Modified by GUIDE v2.5 13-Aug-2011 16:15:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @moduleParentGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @moduleParentGUI_OutputFcn, ...
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


% --- Executes just before moduleParentGUI is made visible.
function moduleParentGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to moduleParentGUI (see VARARGIN)

% Choose default command line output for moduleParentGUI
handles.output = hObject;
mt_idx=find(strcmp(varargin, 'ParentsList'))+1;
handles.ParentsList=varargin{mt_idx};
set(handles.popupmenuParent,'String',handles.ParentsList);
handles.OK=true;
handles.ParentIdx=1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes moduleParentGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = moduleParentGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1}=handles.OK;
varargout{2}=handles.ParentIdx;
varargout{3}=get(handles.editInstance,'String'); 

delete(hObject);



function editInstance_Callback(hObject, eventdata, handles)
% hObject    handle to editInstance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editInstance as text
%        str2double(get(hObject,'String')) returns contents of editInstance as a double


% --- Executes during object creation, after setting all properties.
function editInstance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editInstance (see GCBO)
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
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OK=false;
guidata(handles.figure1,handles);
uiresume(handles.figure1);


% --- Executes on selection change in popupmenuParent.
function popupmenuParent_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuParent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuParent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuParent
handles.ParentIdx=get(hObject,'Value');
guidata(handles.figure1,handles);


% --- Executes during object creation, after setting all properties.
function popupmenuParent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuParent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);