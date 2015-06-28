function varargout = Load_Options(varargin)
% LOAD_OPTIONS MATLAB code for Load_Options.fig
%      LOAD_OPTIONS, by itself, creates a new LOAD_OPTIONS or raises the existing
%      singleton*.
%
%      H = LOAD_OPTIONS returns the handle to a new LOAD_OPTIONS or the handle to
%      the existing singleton*.
%
%      LOAD_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_OPTIONS.M with the given input arguments.
%
%      LOAD_OPTIONS('Property','Value',...) creates a new LOAD_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Load_Options

% Last Modified by GUIDE v2.5 24-Apr-2015 14:57:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Load_Options_OpeningFcn, ...
    'gui_OutputFcn',  @Load_Options_OutputFcn, ...
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


% --- Executes just before Load_Options is made visible.
function Load_Options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Options (see VARARGIN)


% Choose default command line output for LOAD_OPTIONS
handles.output = hObject;

dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'Main_Window_Call'));

if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput) ...
        || (~ishandle(varargin{mainGuiInput+1}))
    
    dontOpen = true;
    
else
    % Set the title
    set(hObject, 'Name', 'Data file load options');
    % Remember the handle, and adjust our position
    handles.MainWindow = varargin{mainGuiInput+1};
    
    % Position to be relative to parent:
    parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
    currentPosition = get(hObject, 'Position');
    
    newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
    newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
    newW = currentPosition(3);
    newH = currentPosition(4);
    
    set(hObject, 'Position', [newX, newY, newW, newH]);
    
    % Get the dafault settings
    Defaults = getappdata(handles.MainWindow, 'Defaults');
    handles.Defaults = Defaults;
    set(handles.Multi_Spec, 'Value', Defaults.MultiSpec);
    
    handles.File_Type_Flag = Defaults.DataFormat;
    switch handles.File_Type_Flag
        case 'Coulter'
            set(handles.Coulter_File_Input, 'Value', 1);
        case 'SALD'
            set(handles.SALD_File_Input, 'Value', 1);
        case 'MicroTrac'
            set(handles.MicroTrac_File_Input, 'Value', 1);
        case 'Cilas'
            set(handles.Cilas_File_Input, 'Value', 1);
        case 'Delimited'
            set(handles.Delimited_File_Input, 'Value', 1);
    end
    
    handles.File_Delimiter = Defaults.FileDelimiter;
    switch handles.File_Delimiter
        case 'Tab'
            set(handles.Delimiter_Choice, 'Value', 1);
        case 'Comma'
            set(handles.Delimiter_Choice, 'Value', 2);
        case 'Space'
            set(handles.Delimiter_Choice, 'Value', 3);
    end
    
end

% Update handles structure
guidata(hObject, handles);

if dontOpen
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
else
    % Set the uiwait
    uiwait(handles.Load_Options_Figure);
end



% --- Outputs from this function are returned to the command line.
function varargout = Load_Options_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(hObject);


% --- Executes when selected object is changed in File_Format_Panel.
function File_Format_Panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in File_Format_Panel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'Coulter_File_Input'
        handles.File_Type_Flag = 'Coulter';
        set(handles.Delimiter_Choice, 'Enable', 'off');
        set(handles.Multi_Spec, 'Enable', 'off');
    case 'SALD_File_Input'
        handles.File_Type_Flag = 'SALD';
        set(handles.Delimiter_Choice, 'Enable', 'off');
        set(handles.Multi_Spec, 'Enable', 'off');
    case 'MicroTrac_File_Input'
        handles.File_Type_Flag = 'MicroTrac';
        set(handles.Delimiter_Choice, 'Enable', 'off');
        set(handles.Multi_Spec, 'Enable', 'off');
    case 'Cilas_File_Input'
        handles.File_Type_Flag = 'Cilas';
        set(handles.Delimiter_Choice, 'Enable', 'off');
        set(handles.Multi_Spec, 'Enable', 'off');
    case 'Delimited_File_Input'
        handles.File_Type_Flag = 'Delimited';
        set(handles.Delimiter_Choice, 'Enable', 'on');
        set(handles.Multi_Spec, 'Enable', 'on');
end

guidata(hObject, handles);

% --- Executes on selection change in Delimiter_Choice.
function Delimiter_Choice_Callback(hObject, eventdata, handles)
% hObject    handle to Delimiter_Choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Delimiter_Choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Delimiter_Choice

contents = cellstr(get(hObject,'String'));
handles.File_Delimiter=contents{get(hObject,'Value')};

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Delimiter_Choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Delimiter_Choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Multi_Spec.
function Multi_Spec_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_Spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Multi_Spec


% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main = handles.MainWindow;

if(ishandle(main))
    % Set the appdata to return
    setappdata(handles.MainWindow, 'File_Delimiter', handles.File_Delimiter);
    setappdata(handles.MainWindow, 'File_Type_Flag', handles.File_Type_Flag);
    setappdata(handles.MainWindow, 'Multi_Spec_Flag', get(handles.Multi_Spec, 'Value'));
end

% Return to the main GUI window
uiresume(handles.Load_Options_Figure);


% --- Executes on button press in Cancel_Button.
function Cancel_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set a cancel flag
setappdata(handles.MainWindow, 'Abort_Cancel', 1);

% Return to the main GUI window
uiresume(handles.Load_Options_Figure);


% --- Executes when user attempts to close Load_Options_Figure.
function Load_Options_Figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Load_Options_Figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set a cancel flag
setappdata(handles.MainWindow, 'Abort_Cancel', 1);

% Set the resume
uiresume(handles.Load_Options_Figure);


% --- Executes on button press in Save_Defaults.
function Save_Defaults_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Defaults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Defaults = handles.Defaults;

% Update the defaults
Defaults.DataFormat = handles.File_Type_Flag;
Defaults.FileDelimiter = handles.File_Delimiter;
Defaults.MultiSpec = get(handles.Multi_Spec, 'Value');

% Save them
Save_User_Defaults(Defaults);

% Save them to the main window appdata
setappdata(handles.MainWindow, 'Defaults', Defaults);


% --- Executes on button press in DB.
function DB_Callback(hObject, eventdata, handles)
% hObject    handle to DB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard
