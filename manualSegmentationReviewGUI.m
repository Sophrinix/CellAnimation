function varargout = manualSegmentationReviewGUI(varargin)
% MANUALSEGMENTATIONREVIEWGUI M-file for manualSegmentationReviewGUI.fig
%      MANUALSEGMENTATIONREVIEWGUI, by itself, creates a new MANUALSEGMENTATIONREVIEWGUI or raises the existing
%      singleton*.
%
%      H = MANUALSEGMENTATIONREVIEWGUI returns the handle to a new MANUALSEGMENTATIONREVIEWGUI or the handle to
%      the existing singleton*.
%
%      MANUALSEGMENTATIONREVIEWGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALSEGMENTATIONREVIEWGUI.M with the given input arguments.
%
%      MANUALSEGMENTATIONREVIEWGUI('Property','Value',...) creates a new MANUALSEGMENTATIONREVIEWGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manualSegmentationReviewGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manualSegmentationReviewGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manualSegmentationReviewGUI

% Last Modified by GUIDE v2.5 29-Sep-2010 23:13:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualSegmentationReviewGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @manualSegmentationReviewGUI_OutputFcn, ...
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


% --- Executes just before manualSegmentationReviewGUI is made visible.
function manualSegmentationReviewGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manualSegmentationReviewGUI (see VARARGIN)

% Choose default command line output for manualSegmentationReviewGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manualSegmentationReviewGUI wait for user response (see UIRESUME)
% uiwait(handles.ManualResegmentation);


% --- Outputs from this function are returned to the command line.
function varargout = manualSegmentationReviewGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in resegmentBlobButton.
function resegmentBlobButton_Callback(hObject, eventdata, handles)
% hObject    handle to resegmentBlobButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resegmentBlob('initialize');


% --- Executes on button press in removeBlobButton.
function removeBlobButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeBlobButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeBlob(hObject, eventdata, handles);


% --- Executes on button press in selectBlobButton.
function selectBlobButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectBlobButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectBlobButton
selectBlobButtonPressed(hObject,eventdata,handles);

% --- Executes on button press in selectObjectButton.
function selectObjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectObjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectObjectButton
selectObjectButtonPressed(hObject,eventdata,handles);


% --- Executes on button press in restoreBlobButton.
function restoreBlobButton_Callback(hObject, eventdata, handles)
% hObject    handle to restoreBlobButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
restoreBlob(hObject, eventdata, handles);


% --- Executes on button press in removeObjectButton.
function removeObjectButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeObjectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeObject(hObject, eventdata, handles);


% --- Executes on button press in undoAllChangesButton.
function undoAllChangesButton_Callback(hObject, eventdata, handles)
% hObject    handle to undoAllChangesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
undoAllChanges(hObject, eventdata, handles);


% --- Executes on button press in saveChangesButton.
function saveChangesButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveChangesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveChanges(hObject, eventdata, handles);


% --- Executes on button press in joinObjectsButton.
function joinObjectsButton_Callback(hObject, eventdata, handles)
% hObject    handle to joinObjectsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
joinObjects('initialize');


% --- Executes on button press in checkboxPrevLabel.
function checkboxPrevLabel_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPrevLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showPreviousLabel();


% --- Executes on button press in checkboxOverlayPrevLabel.
function checkboxOverlayPrevLabel_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxOverlayPrevLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
overlayPreviousLabel();

% Hint: get(hObject,'Value') returns toggle state of checkboxOverlayPrevLabel


% --- Executes on button press in checkboxRawLabel.
function checkboxRawLabel_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxRawLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showRawLabel();

% Hint: get(hObject,'Value') returns toggle state of checkboxRawLabel


% --- Executes on button press in checkboxImage.
function checkboxImage_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
showImage();

% Hint: get(hObject,'Value') returns toggle state of checkboxImage
