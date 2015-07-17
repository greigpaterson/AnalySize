function varargout = Fit_Options(varargin)
% FIT_OPTIONS MATLAB code for Fit_Options.fig
%      FIT_OPTIONS, by itself, creates a new FIT_OPTIONS or raises the existing
%      singleton*.
%
%      H = FIT_OPTIONS returns the handle to a new FIT_OPTIONS or the handle to
%      the existing singleton*.
%
%      FIT_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIT_OPTIONS.M with the given input arguments.
%
%      FIT_OPTIONS('Property','Value',...) creates a new FIT_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Fit_Options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Fit_Options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Fit_Options

% Last Modified by GUIDE v2.5 11-May-2015 16:03:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Fit_Options_OpeningFcn, ...
    'gui_OutputFcn',  @Fit_Options_OutputFcn, ...
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


% --- Executes just before Fit_Options is made visible.
function Fit_Options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Fit_Options (see VARARGIN)

% Choose default command line output for Fit_Options
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
        
    handles.Sel_EM_Data = varargin{3};
    
    % Position to be relative to parent:
    parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
    currentPosition = get(hObject, 'Position');
    % Set x to be directly in the middle, and y so that their tops align.
    newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
    newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
    newW = currentPosition(3);
    newH = currentPosition(4);
    
    set(hObject, 'Position', [newX, newY, newW, newH]);
    
end

% Set some defaults
handles.Fit_Type = 1; % Non-Parametric endmember unmixing problem as default

handles.EM_File_Loaded = 0; % Check if defined EM file is loaded

% Get the maximum number of end members to fit
EM_Max_Default = 10;

X=getappdata(handles.MainWindow, 'Data_To_Fit');
[nData, nVar] = size(X);
handles.EM_Global_Max = min([nData-1, nVar-1, EM_Max_Default]);

set(handles.EM_Max, 'Value', handles.EM_Global_Max, 'String', sprintf('%d', handles.EM_Global_Max) );

% Update handles structure
guidata(hObject, handles);

if dontOpen
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
else
    % Set the uiwait
    uiwait(handles.Fit_Options_Figure);
end

% UIWAIT makes Fit_Options wait for user response (see UIRESUME)
% uiwait(handles.Fit_Options_Figure);


% --- Outputs from this function are returned to the command line.
function varargout = Fit_Options_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(hObject);

% --- Executes when selected object is changed in Fit_Type_Select.
function Fit_Type_Select_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Fit_Type_Select
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    
    case 'Fit_Option1'
        % Non-Parametric End Members
        handles.Fit_Type = 1;
        
        % Turn stuff off
        set(handles.Load_EM_File, 'Enable', 'Off');
        set(handles.Dist_Type, 'Enable', 'Off');
        
        % Turn stuff on
        set(handles.EM_Min_Minus, 'Enable', 'On');
        set(handles.EM_Min_Plus, 'Enable', 'On');
        set(handles.EM_Max_Minus, 'Enable', 'On');
        set(handles.EM_Max_Plus, 'Enable', 'On');
        
    case 'Fit_Option2'
        % Parametric End Members
        handles.Fit_Type = 2;
        
        % Turn stuff off
        set(handles.Load_EM_File, 'Enable', 'Off');
        
        % Turn stuff on
        set(handles.Dist_Type, 'Enable', 'On');
        set(handles.EM_Min_Minus, 'Enable', 'On');
        set(handles.EM_Min_Plus, 'Enable', 'On');
        set(handles.EM_Max_Minus, 'Enable', 'On');
        set(handles.EM_Max_Plus, 'Enable', 'On');
        
    case 'Fit_Option3'
        % Defined End Members
        handles.Fit_Type = 3;
        
        % Turn stuff off
        set(handles.Dist_Type, 'Enable', 'Off');
        set(handles.EM_Min_Minus, 'Enable', 'Off');
        set(handles.EM_Min_Plus, 'Enable', 'Off');
        set(handles.EM_Max_Minus, 'Enable', 'Off');
        set(handles.EM_Max_Plus, 'Enable', 'Off');
        
        % Turn stuff on
        set(handles.Load_EM_File, 'Enable', 'On');
        
end

guidata(hObject, handles);


% --- Executes on button press in Load_EM_File.
function Load_EM_File_Callback(hObject, eventdata, handles)
% hObject    handle to Load_EM_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName, PathName] = uigetfile('*.*','Load the end member file...');

if ~ischar(FileName) && FileName == 0
    % User has cancelled the EM file
    return
end


try
    FID = fopen( strcat(PathName, FileName), 'r');
    
    HL = fgetl(FID); % Get the header line
    S = regexp(HL, '\t', 'split'); % and header names
    nCols = length(S);
    
    % Read the data
    fmt = [repmat('%f\t', 1, nCols -1), '%f\n'];
    input = textscan(FID, fmt, 'Delimiter', '\t');
    fclose(FID);
    
    % Find the end members
    EM_inds = find(cellfun(@(x) strcmp('EM', x(1:2)), S));
    nEnd = length(EM_inds);
    EMs = cell2mat( input(EM_inds) );
    
    % Find the grain size data
    GS_str = 'Grain Size';
    G_inds = cellfun(@(x) strcmp('Gra', x(1:3)), S);
    
    min_string = min(cellfun(@length, S(G_inds)));
    GS_inds = cellfun(@(x) strcmpi(GS_str(1:min_string), x(1:min_string)), S(G_inds));
    GS_Data = cell2mat( input(GS_inds) );
    nVar = length(GS_Data);
    
    % Update the text info
    MSG = [{[FileName, ' successfully loaded.']}; {[sprintf('% d', nEnd), ' end members.']};...
        {[num2str(nVar), ' grain size bins.']}; {[sprintf('%3.3f', min(GS_Data)), ' to ', sprintf('%3.0f', max(GS_Data)), ' microns.']}];
    
    handles.EMs_To_Fit = [GS_Data, EMs];
    guidata(hObject, handles);
    
    handles.EM_File_Loaded = 1; % Loaded flag
    
    msgbox(MSG, 'File loaded', 'modal')
    
catch
    warndlg('End member file could not be loaded.', 'File not loaded', 'modal')
    return
end


% --- Executes on button press in EM_Min_Plus or EM_Min_Minus.
function EM_Min_Select_Callback(hObject, eventdata, handles, str)
% hObject    handle to EM_Min_Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the index pointer and the addresses
index = get(handles.EM_Min, 'Value');
EM_Max = get(handles.EM_Max, 'Value');

% Depending on whether Prev or Next was clicked change the display
switch str
    case 'Minus'
        % Decrease the index by one
        ind = index - 1;
        % If the index is less then one then set it the number of specimens
        % (Nspec)
        if ind < 1
            ind = EM_Max;
        end
    case 'Plus'
        % Increase the index by one
        ind = index + 1;
        
        % If the index is greater than the snumber of specimens set index
        % to 1
        if ind > EM_Max
            ind = 1;
        end
end

set(handles.EM_Min, 'Value', ind, 'String', sprintf('%d', ind));

guidata(hObject,handles);


% --- Executes on button press in EM_Max_Plus or EM_Max_Minus.
function EM_Max_Select_Callback(hObject, eventdata, handles, str)
% hObject    handle to EM_Min_Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the index pointer and the addresses
index = get(handles.EM_Max, 'Value');
EM_Min = get(handles.EM_Min, 'Value');

% Depending on whether Prev or Next was clicked change the display
switch str
    case 'Minus'
        % Decrease the index by one
        ind = index - 1;
        % If the index is less then one then set it the number of specimens
        % (Nspec)
        if ind < EM_Min
            ind = handles.EM_Global_Max;
        end
    case 'Plus'
        % Increase the index by one
        ind = index + 1;
        
        % If the index is greater than the snumber of specimens set index
        % to 1
        if ind > handles.EM_Global_Max
            ind = EM_Min;
        end
end

set(handles.EM_Max, 'Value', ind, 'String', sprintf('%d', ind));

guidata(hObject,handles);


% --- Executes when user attempts to close Fit_Options_Figure.
function Fit_Options_Figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Fit_Options_Figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the fit status to zero and return
Return_struct.FitStatus = 0;

handles.output = Return_struct;
guidata(hObject,handles);

% Return to the main GUI window
uiresume(handles.Fit_Options_Figure);


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
uiresume(handles.Fit_Options_Figure);


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gather together the results, check them, then pass them to the fitting
% functions

% Get the string distribution type
tmpVar = cellstr(get(handles.Dist_Type,'String'));

% Parametric fit parameters
Para_Fit_Params = {get(handles.EM_Min, 'Value'), get(handles.EM_Max, 'Value'), tmpVar(get(handles.Dist_Type, 'Value')) };

% Non-Parametric fit parameters
NPP_Fit_Params = {get(handles.EM_Min, 'Value'), get(handles.EM_Max, 'Value') };

% Get the data
X = getappdata(handles.MainWindow, 'Data_To_Fit');
GS = getappdata(handles.MainWindow, 'Size');

switch handles.Fit_Type
    
    case 1 % Non-Parametric End Members
        
        if get(handles.CB_Weltje, 'Value')==1
            [Cancel_Flag, Abunds, EMs, Fit_Quality] = GetNonParaFit_Weltje(X, NPP_Fit_Params);
        else
            [Cancel_Flag, Abunds, EMs, Fit_Quality] = GetNonParaFit(X, GS, NPP_Fit_Params);
        end
        
        Return_struct.Fit_Type = 'Non-Parametric';
        Return_struct.Abundances = Abunds;
        Return_struct.EndMembers = EMs;
        Return_struct.Fit_Quality = Fit_Quality;
        Return_struct.FitStatus = ~Cancel_Flag; % if cancelled then == 0
                
    case 2 % Parametric End Members
        
        [Cancel_Flag, Abunds, EMs, Dist_Params, Fit_Quality, SelectEM_Data] = GetParaFit(X, GS, Para_Fit_Params, handles.Sel_EM_Data);
        
        Return_struct.Fit_Type = tmpVar(get(handles.Dist_Type, 'Value'));
        Return_struct.Abundances = Abunds;
        Return_struct.EndMembers = EMs;
        Return_struct.Dist_Params = Dist_Params;
        Return_struct.Fit_Quality = Fit_Quality;
        Return_struct.SelectEM_Data = SelectEM_Data;
        Return_struct.FitStatus = ~Cancel_Flag; % if cancelled then == 0
                
    case 3 % Defined End Members
        
        if handles.EM_File_Loaded ~= 1
            warndlg('No end member file is loaded.', 'File not loaded', 'modal')
            return
        end
        
        [Abunds, EMs, Fit_Quality] = GetDefinedFit(X, GS, handles.EMs_To_Fit);
        
        Return_struct.Fit_Type = 'Defined';
        Return_struct.Abundances = Abunds;
        Return_struct.EndMembers = EMs;
        Return_struct.Fit_Quality = Fit_Quality;
        Return_struct.FitStatus = 1;
end

handles.output = Return_struct;
guidata(hObject,handles);

% Return to the main GUI window
uiresume(handles.Fit_Options_Figure);


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


% --- Executes on button press in CB_Weltje.
function CB_Weltje_Callback(hObject, eventdata, handles)
% hObject    handle to CB_Weltje (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_Weltje


% --- Executes on button press in Debug_Me.
function Debug_Me_Callback(hObject, eventdata, handles)
% hObject    handle to Debug_Me (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard
