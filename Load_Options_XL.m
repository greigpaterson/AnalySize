function varargout = Load_Options_XL(varargin)
% LOAD_OPTIONS MATLAB code for Load_Options.fig
%      LOAD_OPTIONS, by itself, creates a new LOAD_OPTIONS_XL or raises the existing
%      singleton*.
%
%      H = LOAD_OPTIONS returns the handle to a new LOAD_OPTIONS_XL or the handle to
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

% Last Modified by GUIDE v2.5 24-Jun-2015 13:09:12

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

% Choose default command line output for LOAD_OPTIONS_XL
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
    handles.Sheets = varargin{3};
        
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
    
    switch Defaults.XLLayout
        case 1
            set(handles.Excel_Input1, 'Value', 1);
            handles.Excel_Layout = 1;
        case 2
            set(handles.Excel_Input2, 'Value', 1);
            handles.Excel_Layout = 2;
            
            % GUI defaults to an active Panel 1 so...
            
            % Turn off panel 1
            set(handles.Input1_Start_Row, 'Enable', 'off');
            set(handles.Input1_Size1, 'Enable', 'off');
            set(handles.Input1_Size2, 'Enable', 'off');
            set(handles.Input1_ID_Col, 'Enable', 'off');
            
            % Turn on panel 2
            set(handles.Input2_Start_Row, 'Enable', 'on');
            set(handles.Input2_Size_Col, 'Enable', 'on');
            set(handles.Input2_ID1, 'Enable', 'on');
            set(handles.Input2_ID2, 'Enable', 'on');
            
        otherwise
            set(handles.Excel_Input1, 'Value', 1);
            handles.Excel_Layout = 1;
    end
    
    set(handles.Input1_Start_Row, 'Value', Defaults.XL1_1, 'String', num2str(Defaults.XL1_1));
    set(handles.Input1_Size1, 'String', Defaults.XL1_2);
    set(handles.Input1_Size2, 'String', Defaults.XL1_3);
    set(handles.Input1_ID_Col, 'String', Defaults.XL1_4);
    
    set(handles.Input2_Start_Row, 'Value', Defaults.XL2_1, 'String', num2str(Defaults.XL2_1));
    set(handles.Input2_ID1, 'String', Defaults.XL2_2);
    set(handles.Input2_ID2, 'String', Defaults.XL2_3);
    set(handles.Input2_Size_Col, 'String', Defaults.XL2_4);
    
    set(handles.Sheet_Select, 'String', handles.Sheets);
    
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
    case 'Excel_Input1'
        handles.Excel_Layout=1;
        
        % Turn on panel 1
        set(handles.Input1_Start_Row, 'Enable', 'on');
        set(handles.Input1_Size1, 'Enable', 'on');
        set(handles.Input1_Size2, 'Enable', 'on');
        set(handles.Input1_ID_Col, 'Enable', 'on');
        
        % Turn off panel 2
        set(handles.Input2_Start_Row, 'Enable', 'off');
        set(handles.Input2_Size_Col, 'Enable', 'off');
        set(handles.Input2_ID1, 'Enable', 'off');
        set(handles.Input2_ID2, 'Enable', 'off');
        
    case 'Excel_Input2'
        handles.Excel_Layout=2;
        
        % Turn off panel 1
        set(handles.Input1_Start_Row, 'Enable', 'off');
        set(handles.Input1_Size1, 'Enable', 'off');
        set(handles.Input1_Size2, 'Enable', 'off');
        set(handles.Input1_ID_Col, 'Enable', 'off');
        
        % Turn on panel 2
        set(handles.Input2_Start_Row, 'Enable', 'on');
        set(handles.Input2_Size_Col, 'Enable', 'on');
        set(handles.Input2_ID1, 'Enable', 'on');
        set(handles.Input2_ID2, 'Enable', 'on');
end

guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%
%%%%  Panel 1  %%%%
%%%%%%%%%%%%%%%%%%%

function Input1_Start_Row_Callback(hObject, eventdata, handles)
% hObject    handle to Input1_Start_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input1_Start_Row as text
%        str2double(get(hObject,'String')) returns contents of Input1_Start_Row as a double

% input should be a number
default_val = handles.Defaults.XL1_1;

if isnan(str2double(get(hObject,'String') )) || str2double(get(hObject,'String') ) < 0
    set(handles.Input1_Start_Row, 'Value', default_val, 'String', num2str(default_val) );
else
    set(handles.Input1_Start_Row, 'Value', str2double(get(hObject,'String') ) );
end

% --- Executes during object creation, after setting all properties.
function Input1_Start_Row_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input1_Start_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Input1_Size1_Callback(hObject, eventdata, handles)
% hObject    handle to Input1_Size1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input1_Size1 as text
%        str2double(get(hObject,'String')) returns contents of Input1_Size1 as a double

% input should be a letter
default_val = handles.Defaults.XL1_2;

% check the input is alphabetic letters, if not set to default
if sum(isletter( get(hObject,'String') )) > 0
    set(handles.Input1_Size1, 'Value', [], 'String', get(hObject,'String') );
else
    set(handles.Input1_Size1, 'Value', [], 'String', default_val );
end

% --- Executes during object creation, after setting all properties.
function Input1_Size1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input1_Size1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Input1_Size2_Callback(hObject, eventdata, handles)
% hObject    handle to Input1_Size2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input1_Size2 as text
%        str2double(get(hObject,'String')) returns contents of Input1_Size2 as a double

% input should be a letter
default_val = handles.Defaults.XL1_3;

% check the input is alphabetic letters, if not set to default
if sum(isletter( get(hObject,'String') )) > 0
    set(handles.Input1_Size2, 'Value', [], 'String', get(hObject,'String') );
else
    set(handles.Input1_Size2, 'Value', [], 'String', default_val);
end

% --- Executes during object creation, after setting all properties.
function Input1_Size2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input1_Size2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Input1_ID_Col_Callback(hObject, eventdata, handles)
% hObject    handle to Input1_ID_Col (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input1_ID_Col as text
%        str2double(get(hObject,'String')) returns contents of Input1_ID_Col as a double

% input should be a letter
default_val = handles.Defaults.XL1_4;

% check the input is alphabetic letters, if not set to default
if sum(isletter( get(hObject,'String') )) > 0
    set(handles.Input1_ID_Col, 'Value', [], 'String', get(hObject,'String') );
else
    set(handles.Input1_ID_Col, 'Value', [], 'String', default_val );
end

% --- Executes during object creation, after setting all properties.
function Input1_ID_Col_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input1_ID_Col (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%
%%%%  Panel 2  %%%%
%%%%%%%%%%%%%%%%%%%

function Input2_Start_Row_Callback(hObject, eventdata, handles)
% hObject    handle to Input2_Start_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input2_Start_Row as text
%        str2double(get(hObject,'String')) returns contents of Input2_Start_Row as a double

% input should be a number
default_val = handles.Defaults.XL2_1;

if isnan(str2double(get(hObject,'String') )) || str2double(get(hObject,'String') ) < 0
    set(handles.Input2_Start_Row, 'Value', default_val, 'String', num2str(default_val) );
else
    set(handles.Input2_Start_Row, 'Value', str2double(get(hObject,'String') ) );
end


% --- Executes during object creation, after setting all properties.
function Input2_Start_Row_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input2_Start_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Input2_ID1_Callback(hObject, eventdata, handles)
% hObject    handle to Input2_ID1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input2_ID1 as text
%        str2double(get(hObject,'String')) returns contents of Input2_ID1 as a double

% input should be a letter
default_val = handles.Defaults.XL2_2;

% check the input is alphabetic letters, if not set to default
if sum(isletter( get(hObject,'String') )) > 0
    set(handles.Input2_ID1, 'Value', [], 'String', get(hObject,'String') );
else
    set(handles.Input2_ID1, 'Value', [], 'String', default_val );
end


% --- Executes during object creation, after setting all properties.
function Input2_ID1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input2_ID1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Input2_ID2_Callback(hObject, eventdata, handles)
% hObject    handle to Input2_ID2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input2_ID2 as text
%        str2double(get(hObject,'String')) returns contents of Input2_ID2 as a double

% input should be a letter
default_val = handles.Defaults.XL2_3;

% check the input is alphabetic letters, if not set to default
if sum(isletter( get(hObject,'String') )) > 0
    set(handles.Input2_ID2, 'Value', [], 'String', get(hObject,'String') );
else
    set(handles.Input2_ID2, 'Value', [], 'String', default_val );
end


% --- Executes during object creation, after setting all properties.
function Input2_ID2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input2_ID2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Input2_Size_Col_Callback(hObject, eventdata, handles)
% hObject    handle to Input2_Size_Col (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Input2_Size_Col as text
%        str2double(get(hObject,'String')) returns contents of Input2_Size_Col as a double

% input should be a letter
default_val = handles.Defaults.XL2_4;

% check the input is alphabetic letters, if not set to default
if sum(isletter( get(hObject,'String') )) > 0
    set(handles.Input2_Size_Col, 'Value', [], 'String', get(hObject,'String') );
else
    set(handles.Input2_Size_Col, 'Value', [], 'String', default_val );
end


% --- Executes during object creation, after setting all properties.
function Input2_Size_Col_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Input2_Size_Col (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gather togetether the needed data
SheetName = handles.Sheets{get(handles.Sheet_Select, 'Value')};

if handles.Excel_Layout == 1
    
    Type_Data=[{handles.Excel_Layout}, {get(handles.Input1_Start_Row, 'Value')},...
        {get(handles.Input1_Size1, 'String')}, {get(handles.Input1_Size2, 'String')},...
        {get(handles.Input1_ID_Col, 'String')}, {SheetName}];
    
else % Layout 2
    Type_Data=[{handles.Excel_Layout}, {get(handles.Input2_Start_Row, 'Value')},...
        {get(handles.Input2_ID1, 'String')}, {get(handles.Input2_ID2, 'String')},...
        {get(handles.Input2_Size_Col, 'String')}, {SheetName}];
end

main = handles.MainWindow;
% Obtain handles using GUIDATA with the caller's handle
if(ishandle(main))
    % Set the appdata to return
    setappdata(handles.MainWindow, 'Type_Data', Type_Data);
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

% Get the dafault settings
Defaults = handles.Defaults;

% Update the defaults
Defaults.XLLayout = handles.Excel_Layout;

Defaults.XL1_1 = get(handles.Input1_Start_Row, 'Value');
Defaults.XL1_2 = get(handles.Input1_Size1, 'String');
Defaults.XL1_3 = get(handles.Input1_Size2, 'String');
Defaults.XL1_4 = get(handles.Input1_ID_Col, 'String');

Defaults.XL2_1 = get(handles.Input2_Start_Row, 'Value');
Defaults.XL2_2 = get(handles.Input2_ID1, 'String');
Defaults.XL2_3 = get(handles.Input2_ID2, 'String');
Defaults.XL2_4 = get(handles.Input2_Size_Col, 'String');

% Save them
Save_User_Defaults(Defaults);

% Save them to the main window appdata
setappdata(handles.MainWindow, 'Defaults', Defaults);


% --- Executes on selection change in Sheet_Select.
function Sheet_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Sheet_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sheet_Select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sheet_Select


% --- Executes during object creation, after setting all properties.
function Sheet_Select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sheet_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
