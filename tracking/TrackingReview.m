function varargout = TrackingReview(varargin)
% TRACKINGREVIEW MATLAB code for TrackingReview.fig
%      	TRACKINGREVIEW, by itself, creates a new TRACKINGREVIEW or raises 
%		the existing singleton*.
%
%      	H = TRACKINGREVIEW returns the handle to a new TRACKINGREVIEW or 
%		the handle to the existing singleton*.
%
%      	TRACKINGREVIEW('CALLBACK',hObject,eventData,handles,...) calls the 
%		local function named CALLBACK in TRACKINGREVIEW.M with the given 
%		input arguments.
%
%      	TRACKINGREVIEW('Property','Value',...) creates a new TRACKINGREVIEW 
%		or raises the existing singleton*.  Starting from the left, property 
%		value pairs are	applied to the GUI before TrackingReview_OpeningFcn 
%		gets called.  An unrecognized property name or invalid value makes 
%		property application stop.  All inputs are passed to 
%		TrackingReview_OpeningFcn via varargin.
%
%      	*See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      	instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackingReview

% Last Modified by GUIDE v2.5 30-Jun-2011 10:18:08

% Begin initialization code - DO NOT EDIT
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @TrackingReview_OpeningFcn, ...
                     'gui_OutputFcn',  @TrackingReview_OutputFcn, ...
                     'gui_LayoutFcn',  [] , ...
                     'gui_Callback',   []);
  if(nargin && ischar(varargin{1}))
    gui_State.gui_Callback = str2func(varargin{1});
  end % if(nargin...

  if(nargout)
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
  else
    gui_mainfcn(gui_State, varargin{:});
  end % if(nargout)
  
end % End initialization code - DO NOT EDIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Output

% --- Outputs from this function are returned to the command line.
function varargout = TrackingReview_OutputFcn(hObject, eventdata, handles) 
  
  % Get default command line output from handles structure
  varargout{1} = handles.output;

end % TrackingReview_OutputFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initialization

% --- Executes just before TrackingReview is made visible.
function TrackingReview_OpeningFcn(hObject, eventdata, handles, varargin)
  
  % Choose default command line output for TrackingReview
  handles.output = hObject;
  handles.saveFile = '';

  % Update handles structure
  guidata(hObject, handles);

  if(size(varargin,2) < 2)
    errordlg(['Must specify number followed by ' ...
              'images object on command line']);
  else
    InitDisplay(handles, varargin{3});
  end % if(size...

end % TrackingReview_OpeningFcn

% --- Draws underlying images, sets up display variables
function InitDisplay(handles, imagesStruct)

  %initialize handles
  handles.startIndex = 1;
  handles.endIndex = size(imagesStruct,2);
  handles.curIndex = 1;
  handles.images = imagesStruct;

  %initialize outlines handles
  handles.outlines = struct();

  %set up object popup menu
  set(handles.ObjectPopUp, ...
      'String', 1:size(handles.images(handles.curIndex).s,1));
  handles.selected = 1;

  %initialize handles
  handles.nums 				= struct();%overwritten numbers
  handles.outlines 			= struct();%outlines around objects
  handles.prevOutlines 		= struct();%outlines around prev objects
  handles.rectangle 		= handle(rectangle);%rectangle
  delete(handles.rectangle);
  guidata(handles.output, handles);

  set(handles.ImageDisplay, 'NextPlot', 'replacechildren');
  DrawDisplay(handles);

end % InitDisplay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the main display

% --- Draws outlines, numbers, etc
function DrawDisplay(handles)

  handles = DeleteRectangle(handles);
  handles = DeleteOutlines(handles);
  handles = DeletePrevOutlines(handles);
  handles = DeleteNums(handles);
  guidata(handles.output, handles);

  %initialize image
  newplot;
  imagesc(handles.image);
  axis image;
  colormap gray;
  set(handles.ImageDisplay, 'NextPlot', 'replacechildren');
  hold on;

  handles = DrawRectangle(handles);
  handles = DrawOutlines(handles);

  %draw track numbers, if applicable
  if(get(handles.DispNumsCheck, 'Value'))
    handles = DrawNums(handles);
  end % if(get(...

  %draw outlines around objects from previous frame, if applicable
  if(get(handles.PrevOutlinesCheck, 'Value'))
    handles = DrawPrevOutlines(handles);
  end % if(get(...

  set(handles.ImageNumInput, 'String', num2str(handles.curIndex));
  set(get(handles.ImageDisplay, 'Children'), 'HitTest', 'off');
  guidata(handles.output, handles);

end % DrawDisplay

% --- Executes on mouse press over axes background.
function ImageDisplay_ButtonDownFcn(hObject, eventdata, handles)

  pos=get(hObject, 'Currentpoint');
  x=int64(pos(1,1));
  y=int64(pos(1,2));
  s=size(handles.images(handles.curIndex).l);
  if(x > 0 && x <= s(2) && y > 0 && y <= s(1))
    if(handles.images(handles.curIndex).l(y,x) > 0)
      set(handles.ObjectPopUp, 'Value', ...
          handles.images(handles.curIndex).l(y,x));        
    end % if handles.image...
  end % if(x...

  handles.selected = get(handles.ObjectPopUp, 'Value');
  handles = DeleteRectangle(handles);
  handles = DrawRectangle(handles);
  guidata(handles.output, handles);

end % ImageDisplay_ButtonDownFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Draws outlines around objects in the frame

%adds outlines around the objects in the current image
function newHandles = DrawOutlines(handles)

  newHandles = handles;

  objList = newHandles.images(newHandles.curIndex).s;
  for(i=1:size(objList))
    newHandles.outlines.(['o' num2str(i)]) = ...
      plot(objList(i).bound(:,2), ...
           objList(i).bound(:,1), ...
           'Color', 'b', ...
           'LineWidth',1.25);
    set(newHandles.outlines.(['o' num2str(i)]), 'HitTest', 'off');
  end % for(i=1...

end % DrawOutlines

%removes outlines fromt the display, if present
function newHandles = DeleteOutlines(handles)

  newHandles = handles;

  outlines = fieldnames(newHandles.outlines);
  for(i=1:size(outlines,1))
    if(newHandles.outlines.(outlines{i}) ~= 0)
      delete(newHandles.outlines.(outlines{i}));
    end % if(newHandles...
    %clear handles.nums.(nums{i});
  end % for(i...
  clear newHandles.outlines;
  newHandles.outlines = struct();

end % DeleteOutlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Draws rectangle around selected object

%Draw rectangles around the selected object
function newHandles = DrawRectangle(handles)

  newHandles = handles;

  %draw rectangle around selected object
  newHandles.rectangle= ...
    rectangle('Position', newHandles.images(newHandles.curIndex)...
						  .s(newHandles.selected).BoundingBox, ...
              'EdgeColor', 'r', ...
              'LineWidth', 2);
  set(newHandles.rectangle, 'HitTest', 'off') ;

end % DrawRectangle

%remove the rectangle around the selected object
function newHandles = DeleteRectangle(handles)

  newHandles = handles;

  %remove old rectangle
  if(ishandle(newHandles.rectangle))
    delete(newHandles.rectangle);
  end % if(ishandle...

end % DeleteRectangle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Displays track numbers

% --- Executes on button press in DispNumsCheck.
function DispNumsCheck_Callback(hObject, eventdata, handles)

  handles = DeleteNums(handles);
  if(get(hObject, 'Value'))
    handles = DrawNums(handles);
  end % if(get...
  guidata(handles.output, handles);

end %DispNumsCheck_Callback

%adds track numbers to display over respective objects
function newHandles = DrawNums(handles)

  newHandles = handles;

  curObjList = newHandles.images(newHandles.curIndex).s;
  for(i=1:size(curObjList))
    trackNum = curObjList(i).trackNum;
    if(trackNum)
      newHandles.nums.(['o' num2str(i)]) = ...
        text(curObjList(i).Centroid(1), ...
             curObjList(i).Centroid(2), ...
             num2str(trackNum), ...
             'Color', 'w');
      set(newHandles.nums.(['o' num2str(i)]), 'HitTest', 'off');
    end % if(tracknum)
  end % for(i=1:...

end % DrawNums

%removes track numbers from display, if present
function newHandles = DeleteNums(handles)

  newHandles = handles;

  nums = fieldnames(newHandles.nums);
  for(i=1:size(nums,1))
    if(newHandles.nums.(nums{i}) ~= 0)
      delete(newHandles.nums.(nums{i}));
    end % if(newHandles...
  end % for(1=1:...
  clear newHandles.nums;
  newHandles.nums = struct();

end % DeleteNums
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Displays outlines of objects in previous image

% --- Executes on button press in PrevOutlinesCheck.
function PrevOutlinesCheck_Callback(hObject, eventdata, handles)

  if(handles.curIndex == 1)
    msgbox('This is the first image.');
    set(hObject, 'Value', 0);
  else
    handles = DeletePrevOutlines(handles);
    if(get(hObject, 'Value'))
        handles = DrawPrevOutlines(handles);
    end % if(get...
    guidata(handles.output, handles);
  end % if(handles...

end % PrevOutlinesCheck_Callback

%adds track numbers to display over respective objects
function newHandles = DrawPrevOutlines(handles)

  newHandles = handles;

  prevObjList = newHandles.images(newHandles.curIndex - 1).s;
  for(i=1:size(prevObjList))
    newHandles.prevOutlines.(['o' num2str(i)]) = ...
      plot(prevObjList(i).bound(:,2), ...
           prevObjList(i).bound(:,1), ...
           'Color', 'r', ...
           'LineWidth',1.25);
    set(newHandles.prevOutlines.(['o' num2str(i)]), 'HitTest', 'off');
  end % for(i=1:...

end % DrawPrevOutlines

%removes track numbers from display, if present
function newHandles = DeletePrevOutlines(handles)

  newHandles = handles;

  prevOutlines = fieldnames(newHandles.prevOutlines);
  for(i=1:size(prevOutlines,1))
    if(newHandles.prevOutlines.(prevOutlines{i}) ~= 0)
      delete(newHandles.prevOutlines.(prevOutlines{i}));
    end % if(newHandles...
  end % for(i=1:...
  clear newHandles.prevOutlines;
  newHandles.prevOutlines = struct();

end % DeletePrevOutlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the next and previous image buttons

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)

  if((handles.curIndex + handles.startIndex - 1) == handles.endIndex)
    msgbox('This is the last image.');
  else
    handles = DeleteNums(handles);
    handles = DeletePrevOutlines(handles);
    handles = DeleteRectangle(handles);

    prevSelectedTrack = ...
	  handles.images(handles.curIndex).s(handles.selected).trackNum;
    handles.curIndex = handles.curIndex + 1;

    %set up object popup menu
    set(handles.ObjectPopUp, ...
        'String', 1:size(handles.images(handles.curIndex).s,1));
    
    handles.selected = 1;
    set(handles.ObjectPopUp, 'Value', handles.selected);

    guidata(handles.output, handles);
    DrawDisplay(handles);
  end % if((handles.curIndex...

end % NextButton_Callback

% --- Executes on button press in PrevImageButton.
function PrevImageButton_Callback(hObject, eventdata, handles)

  if(handles.curIndex == 1)
    msgbox('This is the first image.');
  else
    handles = DeleteNums(handles);
    handles = DeletePrevOutlines(handles);
    handles = DeleteRectangle(handles);

    prevSelectedTrack = ...
	  handles.images(handles.curIndex).s(handles.selected).trackNum;
    handles.curIndex = handles.curIndex - 1;
    
    %set up object popup menu
    set(handles.ObjectPopUp, ...
        'String', 1:size(handles.images(handles.curIndex).s,1));

    handles.selected = 1;
    set(handles.ObjectPopUp, 'Value', handles.selected);    

    guidata(handles.output, handles);
    DrawDisplay(handles);
  end % if(handles.curIndex...

end % PrevImageButton_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the popup menu which allows direct access to objects 
%in the frame

% --- Executes on selection change in ObjectPopUp.
function ObjectPopUp_Callback(hObject, eventdata, handles)

  handles.selected = get(hObject, 'Value');
  handles = DeleteRectangle(handles);
  handles = DrawRectangle(handles);
  guidata(handles.output, handles);

end % ObjectPopUp_Callback

% --- Executes during object creation, after setting all properties.
function ObjectPopUp_CreateFcn(hObject, eventdata, handles)

  if(ispc && isequal(get(hObject,'BackgroundColor'), ...
					 get(0,'defaultUicontrolBackgroundColor')))
    set(hObject,'BackgroundColor','white');
  end % if(ispc...

end % ObjectPopUp_CreateFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the change track number button

% --- Executes on button press in ChangeTrackButton.
function ChangeTrackButton_Callback(hObject, eventdata, handles)

  newTrackNum = inputdlg('New Track Number: ', 'Change Track Number');

  handles = DeleteNums(handles);
  handles = DeletePrevOutlines(handles);
  handles = DeleteRectangle(handles);

  handles.images(handles.curIndex).s(handles.selected).trackNum = ...
    newTrackNum{1};

  guidata(handles.output, handles);
  DrawDisplay(handles);

end % ChangeTrackButton_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the save button

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)

  images = handles.images;
  if(isempty(handles.saveFile))
    [file, path] = uiputfile('', 'Save Tracks');
    save([path file], 'images');
    handles.saveFile = [path file];
  else
    save(handles.saveFile, 'images');
  end % if(isempty...
  guidata(handles.output, handles);

end % SaveButton_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the image number display box
%(also direct access to frame)

% --- Executes when enter is pressed in the image number box
function ImageNumInput_Callback(hObject, eventdata, handles)

  newIndex = str2double(get(hObject, 'String'));
  if(or((newIndex < 1), ...
        (newIndex > (handles.endIndex - handles.startIndex - 1))))
    msgbox('Image number is out of range');
  else
    handles = DeleteNums(handles);
    handles = DeletePrevOutlines(handles);
    handles = DeleteRectangle(handles);

    prevSelectedTrack = ...
	  handles.images(handles.curIndex).s(handles.selected).trackNum;
    handles.curIndex = newIndex;

    %set up object popup menu
    set(handles.ObjectPopUp, ...
        'String', 1:size(handles.images(handles.curIndex).s,1));
    
    handles.selected = 1;
    set(handles.ObjectPopUp, 'Value', handles.selected);    

    guidata(handles.output, handles);
    DrawDisplay(handles);
  end % if(or(newIndex...

end % ImageNumInput_Callback

% --- Executes during object creation, after setting all properties.
function ImageNumInput_CreateFcn(hObject, eventdata, handles)

  if(ispc && isequal(get(hObject,'BackgroundColor'), ...
					 get(0,'defaultUicontrolBackgroundColor')))
    set(hObject,'BackgroundColor','white');
  end % if(ispc...

end % ImageNumInput_CreateFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
