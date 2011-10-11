function varargout = assayEditorGUI(varargin)
% ASSAYEDITORGUI M-file for assayEditorGUI.fig
%      ASSAYEDITORGUI, by itself, creates a new ASSAYEDITORGUI or raises the existing
%      singleton*.
%
%      H = ASSAYEDITORGUI returns the handle to a new ASSAYEDITORGUI or the handle to
%      the existing singleton*.
%
%      ASSAYEDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSAYEDITORGUI.M with the given input arguments.
%
%      ASSAYEDITORGUI('Property','Value',...) creates a new ASSAYEDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before assayEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to assayEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help assayEditorGUI

% Last Modified by GUIDE v2.5 03-Oct-2011 14:00:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @assayEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @assayEditorGUI_OutputFcn, ...
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


% --- Executes just before assayEditorGUI is made visible.
function assayEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assayEditorGUI (see VARARGIN)

% Choose default command line output for assayEditorGUI
handles.output = hObject;
aeMenuNewAssay(hObject, eventdata, handles);
handles=guidata(hObject);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes assayEditorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = assayEditorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuNewAssay_Callback(hObject, eventdata, handles)
% hObject    handle to menuNewAssay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aeMenuNewAssay(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menuOpenAssay_Callback(hObject, eventdata, handles)
% hObject    handle to menuOpenAssay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aeMenuOpenAssay(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menuSaveAssay_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveAssay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.CurrentAssay)
    [file path]=uiputfile('*.m','Save assay as:');
    saveAssay(handles,file,path);
else
    saveAssay(handles,handles.CurrentAssay,handles.AssayPath);
end



% --- Executes on selection change in listboxAvailableModules.
function listboxAvailableModules_Callback(hObject, eventdata, handles)
% hObject    handle to listboxAvailableModules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxAvailableModules contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxAvailableModules
modules_list=get(hObject,'String');
selection_idx=get(hObject,'Value');
set(handles.editModuleDescription,'String',getModuleDescription(modules_list{selection_idx}));
    




% --- Executes during object creation, after setting all properties.
function listboxAvailableModules_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxAvailableModules (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',getModuleList());



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
assay_list=getModuleList();
set(hObject,'String',getModuleDescription(assay_list{1}));


% --- Executes on selection change in listboxCurrentAssay.
function listboxCurrentAssay_Callback(hObject, eventdata, handles)
% hObject    handle to listboxCurrentAssay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modules_list=get(hObject,'String');
selection_idx=get(hObject,'Value');
selection_text=modules_list{selection_idx};
chain_struct=false;
if (strcmp(selection_text(1:9),'<html><i>'))
    chain_struct=true;
else
    %remove the html code
    module_id=stripHTMLFromString(selection_text);    
end
if (chain_struct)
    set(handles.editModuleDescription,'String','List of SubModules.');
else
    modules_list=handles.ModulesList;
    modules_map=handles.ModulesMap;
    module_idx=modules_map.get(module_id);
    module_struct=modules_list{module_idx};
    set(handles.editModuleDescription,'String',getModuleDescription([module_struct.ModuleName '.m']));
end

selection_type=get(handles.figure1,'SelectionType');

if strcmp(selection_type,'open')
    if (chain_struct)
        %expand/collapse sub-modules list
        modules_list=manageChainText(modules_list,selection_idx,handles.ModulesList,handles.ModulesMap);
        set(hObject,'String',modules_list);
    else
        %show the arguments for the selected module
        modules_list=handles.ModulesList;
        modules_map=handles.ModulesMap;
        module_idx=modules_map.get(module_id);
        module_struct=modules_list{module_idx};
        [dlg_ok module_struct]=inputArgumentsGUI('ModulesList',handles.ModulesList,'ModulesMap',handles.ModulesMap,'ModuleStruct',module_struct);
        if (dlg_ok)
            modules_list{module_idx}=module_struct;
            handles.ModulesList=modules_list;
            guidata(handles.figure1,handles);
        end
    end
end
    


% Hints: contents = get(hObject,'String') returns listboxCurrentAssay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxCurrentAssay


% --- Executes during object creation, after setting all properties.
function listboxCurrentAssay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxCurrentAssay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuModuleParameters_Callback(hObject, eventdata, handles)
% hObject    handle to menuModuleParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function assay_context_menu_Callback(hObject, eventdata, handles)
% hObject    handle to assay_context_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonUp.
function pushbuttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moveModule(handles,-1);


% --- Executes on button press in pushbuttonDown.
function pushbuttonDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moveModule(handles,1);


% --- Executes on button press in pushbuttonAdd.
function pushbuttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addModuleToAssay(handles);


% --- Executes during object creation, after setting all properties.
function pushbuttonUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
button_img=imread('up arrow.tif');
button_img=repmat(button_img,[1 1 3]);
set(hObject,'CData',button_img);


% --- Executes during object creation, after setting all properties.
function pushbuttonDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
button_img=imread('down arrow.tif');
button_img=repmat(button_img,[1 1 3]);
set(hObject,'CData',button_img);


% --- Executes during object creation, after setting all properties.
function pushbuttonAdd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
button_img=imread('right arrow.tif');
button_img=repmat(button_img,[1 1 3]);
set(hObject,'CData',button_img);


% --- Executes on button press in pushbuttonRemove.
function pushbuttonRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
removeModuleFromAssay(handles);


% --- Executes during object creation, after setting all properties.
function pushbuttonRemove_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
button_img=imread('remove.tif');
set(hObject,'CData',button_img);


% --------------------------------------------------------------------
function menuSaveAsAssay_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveAsAssay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path]=uiputfile('*.m','Save assay as:');
saveAssay(handles,file,path);



% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function tagCellAnimationHelp_Callback(hObject, eventdata, handles)
% hObject    handle to tagCellAnimationHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open('CellAnimation Help File.pdf');


% --------------------------------------------------------------------
function menuScriptVariables_Callback(hObject, eventdata, handles)
% hObject    handle to menuScriptVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dlg_ok script_variables]=scriptVariablesGUI('ScriptVariables',handles.ScriptVariables);
if (dlg_ok)
    handles.ScriptVariables=script_variables;
    guidata(handles.figure1,handles);
end


% --------------------------------------------------------------------
function menuWrapMatlabFunction_Callback(hObject, eventdata, handles)
% hObject    handle to menuWrapMatlabFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wrapFunction(handles);

% --------------------------------------------------------------------
function tagEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tagEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuAssayDescription_Callback(hObject, eventdata, handles)
% hObject    handle to menuAssayDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dlg_ok assay_description]=assayDescriptionGUI('AssayDescription', handles.AssayDescription);
if (dlg_ok)
    handles.AssayDescription=assay_description;
    guidata(handles.figure1,handles);
end


% --------------------------------------------------------------------
function menuExportScriptVariables_Callback(hObject, eventdata, handles)
% hObject    handle to menuExportScriptVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportScriptVariables(handles);


% --------------------------------------------------------------------
function menuImportScriptVariables_Callback(hObject, eventdata, handles)
% hObject    handle to menuImportScriptVariables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
importScriptVariables(handles);


