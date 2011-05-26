function varargout = SegmentReview(varargin)
% SEGMENTREVIEW M-file for SegmentReview.fig
%      SEGMENTREVIEW, by itself, creates a new SEGMENTREVIEW or raises the existing
%      singleton*.
%
%      H = SEGMENTREVIEW returns the handle to a new SEGMENTREVIEW or the handle to
%      the existing singleton*.
%
%      SEGMENTREVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTREVIEW.M with the given input arguments.
%
%      SEGMENTREVIEW('Property','Value',...) creates a new SEGMENTREVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SegmentReview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SegmentReview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDEs Tools menu.  Choose "GUI allows only one instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegmentReview

% Last Modified by GUIDE v2.5 19-Apr-2011 14:45:34

  % Begin initialization code - DO NOT EDIT
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @SegmentReview_OpeningFcn, ...
                     'gui_OutputFcn',  @SegmentReview_OutputFcn, ...
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
end % SegmentReview


% --- Executes just before SegmentReview is made visible.
function SegmentReview_OpeningFcn(hObject, eventdata, handles, varargin)
  % Choose default command line output for SegmentReview
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  if size(varargin,2) < 2
    errordlg('Must Specify Number followed by Image File on Command Line', 'No Filename');
    close(handles);
  elseif size(varargin,2) < 3
    if InitDisplay(handles, varargin{2}) == 1
      errordlg('Unable to locate image file', 'Invalid Filename');
      close(handles);
    end
  elseif InitDisplay(handles, varargin{2}, varargin{3}) == 1
    errordlg('Unable to locate file', 'Invalid Filename');
    close(handles);
  end

end % SegmentReview_OpeningFcn

function error=InitDisplay(handles, imagefile, segmentfile)

  try
    i = imread(imagefile);
  catch
    error=1;
    return;
  end
  
  if nargin == 3
    try
      load(segmentfile, 's', 'l');
      handles.segmentfile = segmentfile;
    catch
      error=1;
      return;
    end
  else
    fprintf(1,'Segment File was not specified. Running default segmentation.\n');
    [s,l] = NaiveSegment(i, 'BackgroundThreshold', 0.35);
    handles.segmentfile = '';
    fprintf(1,'Segmentation Finished.\n');
  end

  handles.imagefile   = imagefile;
  handles.image       = i;
  handles.segment     = s;
  handles.labels      = l;
  
  % Update handles structure
  guidata(handles.output, handles);

  set(handles.SegmentPopup, 'String', 1:size(s,1));
  
  DrawDisplay(handles);
  
  error=0;
end % InitDisplay

function DrawDisplay(handles)
  axes(handles.ImageDisplay);
  
  h = imagesc(handles.image);
  colormap gray;
  
  outline = get(handles.OutlineButton, 'Value');

  s = handles.segment;
  
  hold on;
  if outline == 1

    colors=pmkmp(20, 'IsoL'); % http://www.mathworks.com/matlabcentral/fileexchange/28982
    for obj=1:size(s,1)
      o=plot(s(obj).bound(:,2), s(obj).bound(:,1),           ...,
           'Color', colors(mod(obj, size(colors,1))+1, :), ...,
           'LineWidth',1.25);
      set(o, 'HitTest', 'off') ;
    end
  end
  
  selected = get(handles.SegmentPopup, 'Value');
  if selected
    set(handles.AreaText,        'String', s(selected).Area);
    set(handles.DebrisCheck,     'Value',  s(selected).debris);
    set(handles.NucleusCheck,    'Value',  s(selected).nucleus);
    set(handles.OverCheck,       'Value',  s(selected).over);
    set(handles.UnderCheck,      'Value',  s(selected).under);
    set(handles.PostMitoticCheck,'Value',  s(selected).postmitotic);
    set(handles.PreMitoticCheck, 'Value',  s(selected).premitotic);
    set(handles.ApoptoticCheck,  'Value',  s(selected).apoptotic);
    set(handles.EdgeCheck,       'Value',  s(selected).edge);
    
    %'Setting'
    %selected
    % s(selected).newborn
    o=rectangle('Position',s(selected).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
    set(o, 'HitTest', 'off') ;
  end
  
  set(h, 'HitTest', 'off') ;
  set(handles.ImageDisplay, 'ButtonDownFcn',{@ImageDisplay_ButtonDownFcn,handles}) ;
end


% UIWAIT makes SegmentReview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SegmentReview_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;
end % SegmentReview_OutputFcn


% --- Executes on button press in OutlineButton.
function OutlineButton_Callback(hObject, eventdata, handles)
  DrawDisplay(handles);
  
end % OutlineButton_Callback


% --- Executes on selection change in SegmentPopup.
function SegmentPopup_Callback(hObject, eventdata, handles)
  DrawDisplay(handles);
end

% --- Executes during object creation, after setting all properties.
function SegmentPopup_CreateFcn(hObject, eventdata, handles)
  % Hint: popupmenu controls usually have a white background on Windows.
  %       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
  
end


function AreaText_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of AreaText as text
%        str2double(get(hObject,'String')) returns contents of AreaText as a double
end

% --- Executes during object creation, after setting all properties.
function AreaText_CreateFcn(hObject, eventdata, handles)

  % Hint: edit controls usually have a white background on Windows.
  %       See ISPC and COMPUTER.
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
      set(hObject,'BackgroundColor','white');
  end
end


% --- Executes on button press in DebrisCheck.
function DebrisCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).debris = get(hObject,'Value');
  guidata(hObject, handles);
end

% --- Executes on button press in NucleusCheck.
function NucleusCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).nucleus = get(hObject,'Value');
  guidata(hObject, handles);
end

% --- Executes on button press in OverCheck.
function OverCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).over = get(hObject,'Value');
  guidata(hObject, handles);
end

% --- Executes on button press in UnderCheck.
function UnderCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).under = get(hObject,'Value');
  guidata(hObject, handles);
end

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
  s = handles.segment;
  l = handles.labels;
  if(isempty(handles.segmentfile))
    [file,path] = uiputfile('','Save Classification');
    save(strcat(path,file), 's', 'l');
  else
    save(handles.segmentfile, 's', 'l');
  end
end

% --- Executes on button press in PostMitoticCheck.
function PostMitoticCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).postmitotic = get(hObject,'Value');
  guidata(hObject, handles);
end


% --- Executes on mouse press over axes background.
function ImageDisplay_ButtonDownFcn(hObject, eventdata, handles)
  pos=get(hObject, 'Currentpoint');
  x=int64(pos(1,1));
  y=int64(pos(1,2));
  s=size(handles.labels);
  if x > 0 && x <= s(2) && y > 0 && y <= s(1)
    l = handles.labels(y,x);
    if l > 0
      set(handles.SegmentPopup, 'Value', l);
      DrawDisplay(handles);
    end
  end
end


% --- Executes on button press in PreMitoticCheck.
function PreMitoticCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).premitotic = get(hObject,'Value');
  guidata(hObject, handles);
end

% --- Executes on button press in ApoptoticCheck.
function ApoptoticCheck_Callback(hObject, eventdata, handles)
  selected = get(handles.SegmentPopup, 'Value');
  handles.segment(selected).apoptotic = get(hObject,'Value');
  guidata(hObject, handles);
end


% --- Executes on button press in EdgeCheck.
function EdgeCheck_Callback(hObject, eventdata, handles)

end