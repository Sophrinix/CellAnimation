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

% Last Modified by GUIDE v2.5 16-Jun-2011 10:20:44

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
    [s,l] = NaiveSegment(i);
    handles.segmentfile = '';
    fprintf(1,'Segmentation Finished.\n');
  end

  handles.imagefile   = imagefile;
  handles.image       = i;
  handles.segment     = s;
  handles.labels      = l;
  handles.trainingsegmentfile = '';
  
  % Update handles structure
  guidata(handles.output, handles);

  set(handles.SegmentPopup, 'String', 1:size(handles.segment,1));
  
  %initialize figure
  axes(handles.ImageDisplay);
  handles.h = imagesc(handles.image);
  colormap gray;
  
  %initialize red rectangle - starts on object #1
  handles.o=rectangle('Position',handles.segment(1).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
  
  %initialize outlines handles
  handles.outlines = struct();
  
  %initialize highlights handles
  handles.highlights = struct();
  
  guidata(handles.output, handles);
  
  DrawDisplay(handles);
  
  error=0;
end % InitDisplay

function DrawDisplay(handles)

  hold on;
  
  
  selected = get(handles.SegmentPopup, 'Value');
  if selected
    set(handles.AreaText,        'String', handles.segment(selected).Area);
    set(handles.DebrisCheck,     'Value',  handles.segment(selected).debris);
    set(handles.NucleusCheck,    'Value',  handles.segment(selected).nucleus);
    set(handles.OverCheck,       'Value',  handles.segment(selected).over);
    set(handles.UnderCheck,      'Value',  handles.segment(selected).under);
    set(handles.PostMitoticCheck,'Value',  handles.segment(selected).postmitotic);
    set(handles.PreMitoticCheck, 'Value',  handles.segment(selected).premitotic);
    set(handles.ApoptoticCheck,  'Value',  handles.segment(selected).apoptotic);
    set(handles.EdgeCheck,       'Value',  handles.segment(selected).edge);
    
    %'Setting'
    %selected
    % handles.segment(selected).newborn
    
    handles = HighlightSelected(handles);
    
    %remove old rectangle
    delete(handles.o);
    
    %draw rectangle around selected object
    handles.o=rectangle('Position',handles.segment(selected).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
    set(handles.o, 'HitTest', 'off') ;
    
    %save rectangle object to allow global access
    guidata(handles.o, handles);
  end
  
  set(handles.h, 'HitTest', 'off') ;
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
  %DrawDisplay(handles);
  
  %remove old outlines, if they exist
  outlines = fieldnames(handles.outlines);
  for(i=1:size(outlines,1))
    if(handles.outlines.(outlines{i}) ~= 0)
      delete(handles.outlines.(outlines{i}));
    end
    handles.outlines.(outlines{i}) = 0;
  end
  
  if(get(handles.OutlineButton, 'Value') == 1)

    colors=pmkmp(20, 'IsoL'); % http://www.mathworks.com/matlabcentral/fileexchange/28982
    for obj=1:size(handles.segment,1)
        handles.outlines.(['o' int2str(obj)])=plot(handles.segment(obj).bound(:,2),...
            handles.segment(obj).bound(:,1),...,
            'Color', colors(mod(obj, size(colors,1))+1, :), ...,
            'LineWidth',1.25);
        set(handles.outlines.(['o' int2str(obj)]), 'HitTest', 'off') ;
    end
  end

  guidata(hObject, handles);
  
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
  handles.segment(get(handles.SegmentPopup, 'Value')).debris = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
end

% --- Executes on button press in NucleusCheck.
function NucleusCheck_Callback(hObject, eventdata, handles)
  handles.segment(get(handles.SegmentPopup, 'Value')).nucleus = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
end

% --- Executes on button press in OverCheck.
function OverCheck_Callback(hObject, eventdata, handles)
  handles.segment(get(handles.SegmentPopup, 'Value')).over = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
end

% --- Executes on button press in UnderCheck.
function UnderCheck_Callback(hObject, eventdata, handles)
  handles.segment(get(handles.SegmentPopup, 'Value')).under = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
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
  DrawDisplay(handles);
end

% --- Executes on button press in PostMitoticCheck.
function PostMitoticCheck_Callback(hObject, eventdata, handles)
  handles.segment(get(handles.SegmentPopup, 'Value')).postmitotic = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
end


% --- Executes on mouse press over axes background.
function ImageDisplay_ButtonDownFcn(hObject, eventdata, handles)
  pos=get(hObject, 'Currentpoint');
  x=int64(pos(1,1));
  y=int64(pos(1,2));
  s=size(handles.labels);
  if x > 0 && x <= s(2) && y > 0 && y <= s(1)
    if handles.labels(y,x) > 0
      set(handles.SegmentPopup, 'Value', handles.labels(y,x));
      DrawDisplay(handles);
    end
  end
end


% --- Executes on button press in PreMitoticCheck.
function PreMitoticCheck_Callback(hObject, eventdata, handles)
  handles.segment(get(handles.SegmentPopup, 'Value')).premitotic = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
end

% --- Executes on button press in ApoptoticCheck.
function ApoptoticCheck_Callback(hObject, eventdata, handles)
  handles.segment(get(handles.SegmentPopup, 'Value')).apoptotic = ...
        get(hObject,'Value');
  guidata(hObject, handles);
  DrawDisplay(handles);
end

% --- Executes on button press in EdgeCheck.
function EdgeCheck_Callback(hObject, eventdata, handles)

end


% --- Executes on button press in SaveToTrainingSet.
function SaveToTrainingSet_Callback(hObject, eventdata, handles)
  if(strcmp(handles.trainingsegmentfile,''))
        answer = inputdlg('Training Set Object: ', 's');
        handles.trainingsegmentfile = answer{1};
        guidata(hObject, handles);
  end
  load(handles.trainingsegmentfile, 's', 'l');
  s(size(s,1)+1) = handles.segment(get(handles.SegmentPopup, 'Value'));
  save(handles.trainingsegmentfile, 's', 'l');
  DrawDisplay(handles);
end


% --- Executes on button press in SelectDebris.
function SelectDebris_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDebris (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

% --- Executes on button press in SelectNuclei.
function SelectNuclei_Callback(hObject, eventdata, handles)
% hObject    handle to SelectNuclei (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

% --- Executes on button press in SelectOver.
function SelectOver_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

% --- Executes on button press in SelectUnder.
function SelectUnder_Callback(hObject, eventdata, handles)
% hObject    handle to SelectUnder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

% --- Executes on button press in SelectPostMitotic.
function SelectPostMitotic_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPostMitotic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

% --- Executes on button press in SelectPreMitotic.
function SelectPreMitotic_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPreMitotic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

% --- Executes on button press in SelectApoptotic.
function SelectApoptotic_Callback(hObject, eventdata, handles)
% hObject    handle to SelectApoptotic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = HighlightSelected(handles);
guidata(hObject, handles);
DrawDisplay(handles);

end

function newhandles = HighlightSelected(handles)

newhandles = handles;
%available options in GUI
selectButtons   = {'SelectDebris',  'SelectNuclei',     'SelectOver',       ...   
                   'SelectUnder',   'SelectPostMitotic','SelectPreMitotic', ... 
                   'SelectApoptotic'};

%classifications which the above apply to (respectively)
classifications = {'debris',        'nucleus',          'over',             ...
                   'under',         'postmitotic',      'premitotic',       ...
                   'apoptotic'};           

               
%remove old highlights, if they exist
highlights = fieldnames(newhandles.highlights);
for(i=1:size(highlights,1))
  delete(newhandles.highlights.(highlights{i}));
  clear newhandles.highlights.(highlights{i});
end
clear newhandles.highlights;
newhandles.highlights = struct();
               

%iterate over the button options               
for(i=1:size(selectButtons,2))
    
    %only act on the ones that are selected
    if(get(newhandles.(selectButtons{1,i}), 'Value') == 1)
        
        hold on;
        colors=pmkmp(20, 'IsoL'); % http://www.mathworks.com/matlabcentral/fileexchange/28982
        
        %outline all objects that are classified this way
        for obj=1:size(newhandles.segment,1)
            if(newhandles.segment(obj).(classifications{1,i}) == 1)
                newhandles.highlights.([classifications{1,i} int2str(obj)])=...
                    plot(newhandles.segment(obj).bound(:,2),              ...
                    newhandles.segment(obj).bound(:,1),                   ...,
                    'Color', colors(mod(obj, size(colors,1))+1, :),    ...,
                    'LineWidth',1.25);
                set(newhandles.highlights.([classifications{1,i} int2str(obj)]),...
                    'HitTest', 'off') ;
            end
        end
        
    end
    
end

end


% --- Executes on button press in SaveImgToTrainingSet.
function SaveImgToTrainingSet_Callback(hObject, eventdata, handles)
% hObject    handle to SaveImgToTrainingSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  if(strcmp(handles.trainingsegmentfile,''))
        answer = inputdlg('Training Set Object: ', 's');
        handles.trainingsegmentfile = answer{1};
        guidata(hObject, handles);
  end
  load(handles.trainingsegmentfile, 's', 'l');
  for(i=1:size(handles.segment,1))
    s(size(s,1)+1) = handles.segment(i);
  end
  save(handles.trainingsegmentfile, 's', 'l');
  DrawDisplay(handles);
end