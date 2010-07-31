function varargout = manualTrackingReviewGUI(varargin)
% MANUALTRACKINGREVIEWGUI M-file for manualTrackingReviewGUI.fig
%      MANUALTRACKINGREVIEWGUI, by itself, creates a new MANUALTRACKINGREVIEWGUI or raises the existing
%      singleton*.
%
%      H = MANUALTRACKINGREVIEWGUI returns the handle to a new MANUALTRACKINGREVIEWGUI or the handle to
%      the existing singleton*.
%
%      MANUALTRACKINGREVIEWGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALTRACKINGREVIEWGUI.M with the given input arguments.
%
%      MANUALTRACKINGREVIEWGUI('Property','Value',...) creates a new MANUALTRACKINGREVIEWGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manualTrackingReviewGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manualTrackingReviewGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manualTrackingReviewGUI

% Last Modified by GUIDE v2.5 30-Jul-2010 20:07:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualTrackingReviewGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @manualTrackingReviewGUI_OutputFcn, ...
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


% --- Executes just before manualTrackingReviewGUI is made visible.
function manualTrackingReviewGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manualTrackingReviewGUI (see VARARGIN)

% Choose default command line output for manualTrackingReviewGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manualTrackingReviewGUI wait for user response (see UIRESUME)
% uiwait(handles.TrackingReview);


% --- Outputs from this function are returned to the command line.
function varargout = manualTrackingReviewGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderTracks_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTracks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderTracksEvent();


% --- Executes during object creation, after setting all properties.
function sliderTracks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTracks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in buttonContinueTrack.
function buttonContinueTrack_Callback(hObject, eventdata, handles)
% hObject    handle to buttonContinueTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
continueTrack();



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStatus1_Callback(hObject, eventdata, handles)
% hObject    handle to editStatus1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStatus1 as text
%        str2double(get(hObject,'String')) returns contents of editStatus1 as a double


% --- Executes during object creation, after setting all properties.
function editStatus1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStatus1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStatus2_Callback(hObject, eventdata, handles)
% hObject    handle to editStatus2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStatus2 as text
%        str2double(get(hObject,'String')) returns contents of editStatus2 as a double


% --- Executes during object creation, after setting all properties.
function editStatus2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStatus2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxLabels.
function checkboxLabels_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxLabels
checkBoxLabelsEvent();



function editStatus3_Callback(hObject, eventdata, handles)
% hObject    handle to editStatus3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStatus3 as text
%        str2double(get(hObject,'String')) returns contents of editStatus3 as a double


% --- Executes during object creation, after setting all properties.
function editStatus3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStatus3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStatusCell_Callback(hObject, eventdata, handles)
% hObject    handle to editStatusCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStatusCell as text
%        str2double(get(hObject,'String')) returns contents of editStatusCell as a double


% --- Executes during object creation, after setting all properties.
function editStatusCell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStatusCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonAddSplit.
function buttonAddSplit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addSplit();


% --- Executes on button press in buttonRemoveSplit.
function buttonRemoveSplit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeSplit();


% --- Executes on button press in buttonManageSelectionLayers.
function buttonManageSelectionLayers_Callback(hObject, eventdata, handles)
% hObject    handle to buttonManageSelectionLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manageSelectionLayers();

% --- Executes on button press in buttonRemoveSelectionLayer.
function buttonRemoveSelectionLayer_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveSelectionLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkboxShowOutlines.
function checkboxShowOutlines_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxShowOutlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxShowOutlines


% --- Executes on button press in buttonSwitchTracks.
function buttonSwitchTracks_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSwitchTracks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switchTracks();


% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveImage_Callback(hObject, eventdata, handles)
% hObject    handle to saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveTrackingImage();