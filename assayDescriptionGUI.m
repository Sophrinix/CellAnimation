function varargout = assayDescriptionGUI(varargin)
% ASSAYDESCRIPTIONGUI M-file for assayDescriptionGUI.fig
%      ASSAYDESCRIPTIONGUI, by itself, creates a new ASSAYDESCRIPTIONGUI or raises the existing
%      singleton*.
%
%      H = ASSAYDESCRIPTIONGUI returns the handle to a new ASSAYDESCRIPTIONGUI or the handle to
%      the existing singleton*.
%
%      ASSAYDESCRIPTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSAYDESCRIPTIONGUI.M with the given input arguments.
%
%      ASSAYDESCRIPTIONGUI('Property','Value',...) creates a new ASSAYDESCRIPTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before assayDescriptionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to assayDescriptionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help assayDescriptionGUI

% Last Modified by GUIDE v2.5 28-Sep-2011 16:55:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @assayDescriptionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @assayDescriptionGUI_OutputFcn, ...
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


% --- Executes just before assayDescriptionGUI is made visible.
function assayDescriptionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assayDescriptionGUI (see VARARGIN)

% Choose default command line output for assayDescriptionGUI
handles.output = hObject;
handles.OK=false;
mt_idx=find(strcmp(varargin, 'AssayDescription'))+1;
assay_description=varargin{mt_idx};
set(handles.editDescription,'String',assay_description);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes assayDescriptionGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = assayDescriptionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1}=handles.OK;
if handles.OK
    varargout{2}=get(handles.editDescription,'String');
else
    varargout{2}='';
end
delete(hObject);


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OK=true;
guidata(handles.figure1,handles);
uiresume(handles.figure1);


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


function editDescription_Callback(hObject, eventdata, handles)
% hObject    handle to editDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDescription as text
%        str2double(get(hObject,'String')) returns contents of editDescription as a double


% --- Executes during object creation, after setting all properties.
function editDescription_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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




