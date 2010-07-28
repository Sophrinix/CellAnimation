function varargout = addLayerGUI(varargin)
% ADDLAYERGUI M-file for addLayerGUI.fig
%      ADDLAYERGUI, by itself, creates a new ADDLAYERGUI or raises the existing
%      singleton*.
%
%      H = ADDLAYERGUI returns the handle to a new ADDLAYERGUI or the handle to
%      the existing singleton*.
%
%      ADDLAYERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDLAYERGUI.M with the given input arguments.
%
%      ADDLAYERGUI('Property','Value',...) creates a new ADDLAYERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addLayerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addLayerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addLayerGUI

% Last Modified by GUIDE v2.5 23-Jul-2010 23:10:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addLayerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @addLayerGUI_OutputFcn, ...
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


% --- Executes just before addLayerGUI is made visible.
function addLayerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addLayerGUI (see VARARGIN)

% Choose default command line output for addLayerGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes addLayerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = addLayerGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in comboLogicConnector.
function comboLogicConnector_Callback(hObject, eventdata, handles)
% hObject    handle to comboLogicConnector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboLogicConnector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboLogicConnector


% --- Executes during object creation, after setting all properties.
function comboLogicConnector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboLogicConnector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboCellProperty.
function comboCellProperty_Callback(hObject, eventdata, handles)
% hObject    handle to comboCellProperty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboCellProperty contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboCellProperty


% --- Executes during object creation, after setting all properties.
function comboCellProperty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboCellProperty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboOperator.
function comboOperator_Callback(hObject, eventdata, handles)
% hObject    handle to comboOperator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboOperator contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboOperator


% --- Executes during object creation, after setting all properties.
function comboOperator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboOperator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editValue_Callback(hObject, eventdata, handles)
% hObject    handle to editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editValue as text
%        str2double(get(hObject,'String')) returns contents of editValue as a double


% --- Executes during object creation, after setting all properties.
function editValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSelectionLayerName_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectionLayerName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectionLayerName as text
%        str2double(get(hObject,'String')) returns contents of editSelectionLayerName as a double


% --- Executes during object creation, after setting all properties.
function editSelectionLayerName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectionLayerName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSaveLayer.
function buttonSaveLayer_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveLayer();


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addLayerCancel();


% --- Executes on button press in buttonAddCondition.
function buttonAddCondition_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddCondition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addCondition();


% --- Executes on selection change in comboColor.
function comboColor_Callback(hObject, eventdata, handles)
% hObject    handle to comboColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboColor


% --- Executes during object creation, after setting all properties.
function comboColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
