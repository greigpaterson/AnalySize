function varargout = Tern_Set_Symbol(varargin)
% TERN_SET_SYMBOL MATLAB code for Tern_Set_Symbol.fig
%      TERN_SET_SYMBOL, by itself, creates a new TERN_SET_SYMBOL or raises the existing
%      singleton*.
%
%      H = TERN_SET_SYMBOL returns the handle to a new TERN_SET_SYMBOL or the handle to
%      the existing singleton*.
%
%      TERN_SET_SYMBOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TERN_SET_SYMBOL.M with the given input arguments.
%
%      TERN_SET_SYMBOL('Property','Value',...) creates a new TERN_SET_SYMBOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Tern_Set_Symbol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Tern_Set_Symbol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Tern_Set_Symbol

% Last Modified by GUIDE v2.5 23-Apr-2015 17:28:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tern_Set_Symbol_OpeningFcn, ...
                   'gui_OutputFcn',  @Tern_Set_Symbol_OutputFcn, ...
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


% --- Executes just before Tern_Set_Symbol is made visible.
function Tern_Set_Symbol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Tern_Set_Symbol (see VARARGIN)

% Choose default command line output for Tern_Set_Symbol
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
    handles.Defaults = getappdata(varargin{3}, 'Defaults');
    handles.TernWindow = varargin{4};
end

% Position to be relative to parent:
parentPosition = get(handles.TernWindow, 'Position');
currentPosition = get(hObject, 'Position');

newX = parentPosition(1) + (parentPosition(3)/1.2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/1.25 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);


% Get the data from previous window
handles.Plot_Symbol = DataTransfer.Plot_Symbol;
handles.Symbol_Size = DataTransfer.Symbol_Size;
handles.Symbol_Color = DataTransfer.Symbol_Color;
handles.Face_Color = DataTransfer.Face_Color;

handles.All_Symbols = {'^', 'o', 'd', '*', 's', '.', '+'};

% Get the input symbol propoerties to set the deafults
% set the radiobutton
Symb_ind=find(strcmpi(handles.Plot_Symbol, handles.All_Symbols));
Symb_Name = strcat('Sym', sprintf('%d', Symb_ind));
set(handles.(Symb_Name), 'Value', 1);

% Set the filled checkbox
if strcmpi(handles.Face_Color, 'none')
    set(handles.CB_Filled, 'Value', 0);
else
    set(handles.CB_Filled, 'Value', 1);
end

% Set the symbol size
set(handles.Size_Select, 'Value', handles.Symbol_Size - 4 );

% Update handles structure
guidata(hObject, handles);

% Make the plot
Update_Plot(handles)

uiwait(handles.Tern_Set_Symbol_Fig);


% --- Outputs from this function are returned to the command line.
function varargout = Tern_Set_Symbol_OutputFcn(hObject, eventdata, handles) 
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
Return.Plot_Symbol = handles.Plot_Symbol;
Return.Symbol_Size = handles.Symbol_Size;
Return.Symbol_Color = handles.Symbol_Color;

if get(handles.CB_Filled,'Value')
    Return.Face_Color = handles.Symbol_Color;
else
    Return.Face_Color = 'none';
end

handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Tern_Set_Symbol_Fig);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Tern_Set_Symbol_Fig);

% --- Executes when user attempts to close Tern_Set_Symbol_Fig.
function Tern_Set_Symbol_Fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Tern_Set_Symbol_Fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Tern_Set_Symbol_Fig);

% --- Executes on button press in Set_Color.
function Set_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Symbol_Color = uisetcolor(handles.Symbol_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


function Update_Plot(handles)

Color = handles.Symbol_Color;
Size = handles.Symbol_Size;

% Check for filled
if get(handles.CB_Filled,'Value')
    FaceColor = Color;
else
    FaceColor = 'none';
end

cla(handles.Symbol_Axes);

hold(handles.Symbol_Axes, 'on')
plot(handles.Symbol_Axes, 0.5, 7, '^', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
plot(handles.Symbol_Axes, 0.5, 6, 'o', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
plot(handles.Symbol_Axes, 0.5, 5, 'd', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
plot(handles.Symbol_Axes, 0.5, 4, '*', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
plot(handles.Symbol_Axes, 0.5, 3, 's', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
plot(handles.Symbol_Axes, 0.5, 2, '.', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
plot(handles.Symbol_Axes, 0.5, 1, '+', 'Color', Color, 'MarkerSize', Size, 'MarkerFaceColor', FaceColor);
hold(handles.Symbol_Axes, 'off')
set(handles.Symbol_Axes, 'Xlim', [0, 1], 'Ylim', [0.5, 7.5]);


% --- Executes on selection change in Size_Select.
function Size_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Size_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Size_Select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Size_Select

contents = cellstr(get(hObject,'String'));
handles.Symbol_Size = str2double(contents{get(hObject,'Value')});

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes during object creation, after setting all properties.
function Size_Select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Size_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_Filled.
function CB_Filled_Callback(hObject, eventdata, handles)
% hObject    handle to CB_Filled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_Filled

% Update the plot
Update_Plot(handles)


% --- Executes on button press in DB_ME.
function DB_ME_Callback(hObject, eventdata, handles)
% hObject    handle to DB_ME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


% --- Executes when selected object is changed in Symbol_Select.
function Symbol_Select_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Symbol_Select 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'Sym1'
        handles.Plot_Symbol = '^';
    case 'Sym2'
        handles.Plot_Symbol = 'o';
    case 'Sym3'
        handles.Plot_Symbol = 'd';
    case 'Sym4'
        handles.Plot_Symbol = '*';
    case 'Sym5'
        handles.Plot_Symbol = 's';
    case 'Sym6'
        handles.Plot_Symbol = '.';
    case 'Sym7'
        handles.Plot_Symbol = '+';
end

guidata(hObject, handles);


% --- Executes on button press in Set_Default.
function Set_Default_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Defaults = handles.Defaults;

% Update the defaults
Defaults.Tern_Plot_Color = handles.Symbol_Color;
Defaults.TernSymbol = handles.Plot_Symbol;
Defaults.TernSymbolSize = handles.Symbol_Size;

if get(handles.CB_Filled,'Value')
    Defaults.TernFaceColor = 'filled';
else
    Defaults.TernFaceColor = handles.Face_Color;
end

% Save them
Save_User_Defaults(Defaults);

% Save them to the main window appdata
setappdata(handles.MainWindow, 'Defaults', Defaults);
