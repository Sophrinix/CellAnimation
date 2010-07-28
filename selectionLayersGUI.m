function varargout = selectionLayersGUI(varargin)
% SELECTIONLAYERSGUI M-file for selectionLayersGUI.fig
%      SELECTIONLAYERSGUI, by itself, creates a new SELECTIONLAYERSGUI or raises the existing
%      singleton*.
%
%      H = SELECTIONLAYERSGUI returns the handle to a new SELECTIONLAYERSGUI or the handle to
%      the existing singleton*.
%
%      SELECTIONLAYERSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTIONLAYERSGUI.M with the given input arguments.
%
%      SELECTIONLAYERSGUI('Property','Value',...) creates a new SELECTIONLAYERSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectionLayersGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectionLayersGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectionLayersGUI

% Last Modified by GUIDE v2.5 26-Jul-2010 15:40:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectionLayersGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @selectionLayersGUI_OutputFcn, ...
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


% --- Executes just before selectionLayersGUI is made visible.
function selectionLayersGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectionLayersGUI (see VARARGIN)

% Choose default command line output for selectionLayersGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectionLayersGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selectionLayersGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listboxSelectionLayers.
function listboxSelectionLayers_Callback(hObject, eventdata, handles)
% hObject    handle to listboxSelectionLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxSelectionLayers contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxSelectionLayers


% --- Executes during object creation, after setting all properties.
function listboxSelectionLayers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxSelectionLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddLayer.
function buttonAddLayer_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addLayer();


% --- Executes on button press in buttonRemoveLayer.
function buttonRemoveLayer_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeLayer();
