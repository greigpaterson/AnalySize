function varargout = Censor_Data(varargin)
% CENSOR_DATA MATLAB code for Censor_Data.fig
%      CENSOR_DATA, by itself, creates a new CENSOR_DATA or raises the existing
%      singleton*.
%
%      H = CENSOR_DATA returns the handle to a new CENSOR_DATA or the handle to
%      the existing singleton*.
%
%      CENSOR_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CENSOR_DATA.M with the given input arguments.
%
%      CENSOR_DATA('Property','Value',...) creates a new CENSOR_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Censor_Data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Censor_Data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Censor_Data

% Last Modified by GUIDE v2.5 22-Apr-2015 09:41:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Censor_Data_OpeningFcn, ...
    'gui_OutputFcn',  @Censor_Data_OutputFcn, ...
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


% --- Executes just before Censor_Data is made visible.
function Censor_Data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Censor_Data (see VARARGIN)

% Choose default command line output for Censor_Data
handles.output = hObject;

DataTransfer = find(strcmp(varargin, 'DataTransfer'));
if (isempty(DataTransfer)) ...
        || (length(varargin) <= DataTransfer)% ...
    
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
    
else
    DataTransfer = varargin{DataTransfer+1};
    handles.MainWindow = varargin{3};
end


% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
currentPosition = get(hObject, 'Position');

newX = parentPosition(1) + (parentPosition(3)/1.45  - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/1.25 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);

set(hObject, 'Position', [newX, newY, newW, newH]);

handles.All_Data = DataTransfer.Data;
handles.All_GS = DataTransfer.Size;

% Vector of grain sizes for indexing
GS(:,1) = handles.All_GS{1};
GS(:,2) = log(GS(:,1));
GS(:,3) = -( log10(GS(:,1)./1e3)./log10(2));

handles.GS = GS;

handles.GS_Min = 0;
handles.GS_Max = min(handles.GS(:,1));

set(handles.GS_Min_input, 'String', sprintf('%3.3f', handles.GS_Min) );
set(handles.GS_Max_input, 'String', sprintf('%3.3f', handles.GS_Max) );

set(handles.Labels, 'Xlim', [0, 1], 'Ylim', [0, 1.5]);
text(-0.1, 0.37, '\mu{m}', 'FontSize', 11, 'FontUnits', 'Pixels')
text(-0.1, 1.27, '\mu{m}', 'FontSize', 11, 'FontUnits', 'Pixels')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Censor_Data wait for user response (see UIRESUME)
uiwait(handles.Censor_Data_Figure);


% --- Outputs from this function are returned to the command line.
function varargout = Censor_Data_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(hObject);


% --- Executes when user attempts to close Censor_Data_Figure.
function Censor_Data_Figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Censor_Data_Figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Censor_Data_Figure);
% delete(hObject);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Censor_Data_Figure);


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check the bounds for comaptibility
Compatible = handles.GS_Min < handles.GS_Max;

if ~Compatible
    warndlg('Lower bound should be less than upper bound.', 'Incompatible bounds', 'modal')
    return;
else
    % Do the censoring
    
    % Set the cancel flag to zero
    Return.CancelFlag = 0;
    
    % Set the data to local variables
    All_Data = handles.All_Data;
    All_GS = handles.All_GS;
    GS = handles.GS;
    
    % Get a logical array of indices to exclude
    inds = (GS(:,1) > handles.GS_Min & GS(:,1) < handles.GS_Max);
    
    % Set the data to return
    Return.All_Data = cellfun(@(x) x(~inds), All_Data, 'UniformOutput', 0); % Remove the indices
    Return.All_Data = cellfun(@(x) x./sum(x), Return.All_Data, 'UniformOutput', 0); % renormlaize to sum-to-one
    Return.All_GS = cellfun(@(x) x(~inds), All_GS, 'UniformOutput', 0);
    
    handles.output = Return;
    guidata(hObject,handles);
    
    uiresume(handles.Censor_Data_Figure);
end



function GS_Min_input_Callback(hObject, eventdata, handles)
% hObject    handle to GS_Min_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GS_Min_input as text
%        str2double(get(hObject,'String')) returns contents of GS_Min_input as a double

new_val=str2double(get(hObject,'String') );

if isnan(new_val) || new_val < 0
    set(handles.GS_Min_input, 'String', sprintf('%3.3f', handles.GS_Min));
elseif new_val > handles.GS_Max
%     set(handles.GS_Min_input, 'String', sprintf('%3.3f', handles.GS_Max));
%     handles.GS_Min = handles.GS_Max;
    handles.GS_Min = new_val;
    warndlg('Lower bound should be less than upper bound.', 'Incompatible bounds', 'modal')
else
    set(handles.GS_Min_input, 'String', sprintf('%3.3f', max(new_val)));
    handles.GS_Min = new_val;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function GS_Min_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GS_Min_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GS_Max_input_Callback(hObject, eventdata, handles)
% hObject    handle to GS_Max_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GS_Max_input as text
%        str2double(get(hObject,'String')) returns contents of GS_Max_input as a double

new_val=str2double(get(hObject,'String') );

if isnan(new_val) || new_val > max(handles.GS(:,1))
    set(handles.GS_Max_input, 'String', sprintf('%3.3f', max(handles.GS(:,1))) );
elseif new_val < handles.GS_Min
%     set(handles.GS_Max_input, 'String', sprintf('%3.3f', handles.GS_Min));
%     handles.GS_Max = handles.GS_Min;
    handles.GS_Max = new_val;
    warndlg('Upper bound should be greater than lower bound.', 'Incompatible bounds', 'modal')
else
    set(handles.GS_Max_input, 'String', sprintf('%3.3f', max(new_val)));
    handles.GS_Max = new_val;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function GS_Max_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GS_Max_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
