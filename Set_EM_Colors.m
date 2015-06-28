function varargout = Set_EM_Colors(varargin)
% SET_EM_COLORS MATLAB code for Set_EM_Colors.fig
%      SET_EM_COLORS, by itself, creates a new SET_EM_COLORS or raises the existing
%      singleton*.
%
%      H = SET_EM_COLORS returns the handle to a new SET_EM_COLORS or the handle to
%      the existing singleton*.
%
%      SET_EM_COLORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SET_EM_COLORS.M with the given input arguments.
%
%      SET_EM_COLORS('Property','Value',...) creates a new SET_EM_COLORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Set_EM_Colors_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Set_EM_Colors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Set_EM_Colors

% Last Modified by GUIDE v2.5 23-Apr-2015 18:40:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Set_EM_Colors_OpeningFcn, ...
    'gui_OutputFcn',  @Set_EM_Colors_OutputFcn, ...
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


% --- Executes just before Set_EM_Colors is made visible.
function Set_EM_Colors_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Set_EM_Colors (see VARARGIN)

% Choose default command line output for Set_EM_Colors
handles.output = hObject;

% Color_Mat is the return matrix
handles.Color_Mat = varargin{1};
handles.MainWindow = varargin{2};
handles.Defaults = getappdata(varargin{2}, 'Defaults');


% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position');
currentPosition = get(hObject, 'Position');

newX = parentPosition(1) + (parentPosition(3)/3.8 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/1.525 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);


handles.All_Labels = {'Set_EM1', 'Set_EM2', 'Set_EM3', 'Set_EM4', 'Set_EM5',...
    'Set_EM6', 'Set_EM7', 'Set_EM8', 'Set_EM9', 'Set_EM10'};

for ii = 1:10
    set(handles.(handles.All_Labels{ii}), 'ForegroundColor', handles.Color_Mat(ii,:));
end

% Update handles structure
guidata(hObject, handles);

uiwait(handles.Set_EM_Colors_Fig);


% --- Outputs from this function are returned to the command line.
function varargout = Set_EM_Colors_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(hObject);

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 0;
Return.New_Colors = handles.Color_Mat;

handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Set_EM_Colors_Fig);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Set_EM_Colors_Fig);

% --- Executes when user attempts to close Set_EM_Colors_Fig.
function Set_EM_Colors_Fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Set_EM_Colors_Fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Set_EM_Colors_Fig);

% --- Executes on button press in Save_Default.
function Save_Default_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Defaults = handles.Defaults;

% Update the defaults
Defaults.EM_Plot_Color = handles.Color_Mat;

% Save them
Save_User_Defaults(Defaults);

setappdata(handles.MainWindow, 'Defaults', Defaults);


% --- Executes on button press in Set_EM1.
function Set_EM1_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(1,:) = uisetcolor(handles.Color_Mat(1,:));
set(handles.Set_EM1, 'ForegroundColor', handles.Color_Mat(1,:));
guidata(hObject, handles);


% --- Executes on button press in Set_EM2.
function Set_EM2_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(2,:) = uisetcolor(handles.Color_Mat(2,:));
set(handles.Set_EM2, 'ForegroundColor', handles.Color_Mat(2,:));
guidata(hObject, handles);


% --- Executes on button press in Set_EM3.
function Set_EM3_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(3,:) = uisetcolor(handles.Color_Mat(3,:));
set(handles.Set_EM3, 'ForegroundColor', handles.Color_Mat(3,:));
guidata(hObject, handles);


% --- Executes on button press in Set_EM4.
function Set_EM4_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(4,:) = uisetcolor(handles.Color_Mat(4,:));
set(handles.Set_EM4, 'ForegroundColor', handles.Color_Mat(4,:));
guidata(hObject, handles);

% --- Executes on button press in Set_EM5.
function Set_EM5_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(5,:) = uisetcolor(handles.Color_Mat(5,:));
set(handles.Set_EM5, 'ForegroundColor', handles.Color_Mat(5,:));
guidata(hObject, handles);

% --- Executes on button press in Set_EM6.
function Set_EM6_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(6,:) = uisetcolor(handles.Color_Mat(6,:));
set(handles.Set_EM6, 'ForegroundColor', handles.Color_Mat(6,:));
guidata(hObject, handles);

% --- Executes on button press in Set_EM7.
function Set_EM7_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(7,:) = uisetcolor(handles.Color_Mat(7,:));
set(handles.Set_EM7, 'ForegroundColor', handles.Color_Mat(7,:));
guidata(hObject, handles);

% --- Executes on button press in Set_EM8.
function Set_EM8_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(8,:) = uisetcolor(handles.Color_Mat(8,:));
set(handles.Set_EM8, 'ForegroundColor', handles.Color_Mat(8,:));
guidata(hObject, handles);

% --- Executes on button press in Set_EM9.
function Set_EM9_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(9,:) = uisetcolor(handles.Color_Mat(9,:));
set(handles.Set_EM9, 'ForegroundColor', handles.Color_Mat(9,:));
guidata(hObject, handles);

% --- Executes on button press in Set_EM10.
function Set_EM10_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Color_Mat(10,:) = uisetcolor(handles.Color_Mat(10,:));
set(handles.Set_EM10, 'ForegroundColor', handles.Color_Mat(10,:));
guidata(hObject, handles);
