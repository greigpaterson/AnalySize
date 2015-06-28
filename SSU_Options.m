function varargout = SSU_Options(varargin)
% SSU_OPTIONS MATLAB code for SSU_Options.fig
%      SSU_OPTIONS, by itself, creates a new SSU_OPTIONS or raises the existing
%      singleton*.
%
%      H = SSU_OPTIONS returns the handle to a new SSU_OPTIONS or the handle to
%      the existing singleton*.
%
%      SSU_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SSU_OPTIONS.M with the given input arguments.
%
%      SSU_OPTIONS('Property','Value',...) creates a new SSU_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SSU_Options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SSU_Options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SSU_Options

% Last Modified by GUIDE v2.5 25-May-2015 11:44:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SSU_Options_OpeningFcn, ...
                   'gui_OutputFcn',  @SSU_Options_OutputFcn, ...
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


% --- Executes just before SSU_Options is made visible.
function SSU_Options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SSU_Options (see VARARGIN)

% Choose default command line output for SSU_Options
handles.output = hObject;

dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'Main_Window_Call'));
if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput) ...
        || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Set the title
    set(hObject, 'Name', 'Choose the fit type');
    % Remember the handle, and adjust our position
    handles.MainWindow = varargin{mainGuiInput+1};
    
    
    % Position to be relative to parent:
    parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
    currentPosition = get(hObject, 'Position');
    % Set x to be directly in the middle
    newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
    newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
    newW = currentPosition(3);
    newH = currentPosition(4);
    
    set(hObject, 'Position', [newX, newY, newW, newH]);
    
end

% Get the maximum number of end members to fit
EM_Max_Default = 10;

X=getappdata(handles.MainWindow, 'Data_To_Fit');
[nData, nVar] = size(X);
handles.EM_Global_Max = min([nData-1, nVar-1, EM_Max_Default]);

start_val = min([handles.EM_Global_Max, 3]);

set(handles.EM_Max, 'Value', start_val, 'String', sprintf('%d', start_val) );

% Update handles structure
guidata(hObject, handles);

if dontOpen
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
else
    % Set the uiwait
    uiwait(handles.SSU_Options_Fig);
end


% --- Outputs from this function are returned to the command line.
function varargout = SSU_Options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(hObject);


% --- Executes when user attempts to close SSU_Options_Fig.
function SSU_Options_Fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SSU_Options_Fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the fit status to zero and return
Return_struct.FitStatus = 0;

handles.output = Return_struct;
guidata(hObject,handles);

% Return to the main GUI window
uiresume(handles.SSU_Options_Fig);

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the fit status to zero and return
Return_struct.FitStatus = 0;

handles.output = Return_struct;
guidata(hObject,handles);

% Return to the main GUI window
uiresume(handles.SSU_Options_Fig);

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gather together the results, check them, then pass them to the fitting
% functions

% Get the string variables and var level to pass to the fitting routines
tmpVar = cellstr(get(handles.Dist_Type,'String'));

% Parametric fit parameters
Para_Fit_Params = {get(handles.EM_Max, 'Value'), tmpVar(get(handles.Dist_Type, 'Value')),...
    get(handles.Abund_Limit, 'Value')./100, get(handles.EMA_Initial, 'Value') };

% Get the data
X = getappdata(handles.MainWindow, 'Data_To_Fit');
GS = getappdata(handles.MainWindow, 'Size');

% Call the fitting function
[Cancel_Flag, Abunds, EMs, Dist_Params, Fit_Quality] = GetSSUFit(X, GS, Para_Fit_Params);

% Set the return variables
Return_struct.Fit_Type = ['SSU - ', char(tmpVar(get(handles.Dist_Type, 'Value'))) ];
Return_struct.Abundances = Abunds;
Return_struct.EndMembers = EMs;
Return_struct.Dist_Params = Dist_Params;
Return_struct.Fit_Quality = Fit_Quality;
Return_struct.FitStatus = ~Cancel_Flag; % if cancelled then == 0

handles.output = Return_struct;
guidata(hObject,handles);

uiresume(handles.SSU_Options_Fig);


% --- Executes on button press in EM_Max_Plus or EM_Max_Minus.
function EM_Max_Select_Callback(hObject, eventdata, handles, str)
% hObject    handle to EM_Min_Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the index pointer and the addresses
index = get(handles.EM_Max, 'Value');

% Depending on whether Prev or Next was clicked change the display
switch str
    case 'Minus'
        % Decrease the index by one
        ind = index - 1;
        % If the index is less then one then set it the number of specimens
        % (Nspec)
        if ind < 1
            ind = handles.EM_Global_Max;
        end
    case 'Plus'
        % Increase the index by one
        ind = index + 1;
        % If the index is greater than the snumber of specimens set index
        % to 1
        if ind > handles.EM_Global_Max
            ind = 1;
        end
end

set(handles.EM_Max, 'Value', ind, 'String', sprintf('%d', ind));

guidata(hObject,handles);


% --- Executes on selection change in Dist_Type.
function Dist_Type_Callback(hObject, eventdata, handles)
% hObject    handle to Dist_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Dist_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dist_Type


% --- Executes during object creation, after setting all properties.
function Dist_Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dist_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DB_ME.
function DB_ME_Callback(hObject, eventdata, handles)
% hObject    handle to DB_ME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard

function Abund_Limit_Callback(hObject, eventdata, handles)
% hObject    handle to Abund_Limit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Abund_Limit as text
%        str2double(get(hObject,'String')) returns contents of Abund_Limit as a double

% input should be a number
default_val = 1.0;

if isnan(str2double(get(hObject,'String') )) || str2double(get(hObject,'String') ) < 0
    set(handles.Abund_Limit, 'Value', default_val, 'String', num2str(default_val) );
else
    set(handles.Abund_Limit, 'Value', str2double(get(hObject,'String') ) );
end


% --- Executes during object creation, after setting all properties.
function Abund_Limit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Abund_Limit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EMA_Initial.
function EMA_Initial_Callback(hObject, eventdata, handles)
% hObject    handle to EMA_Initial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EMA_Initial
