function varargout = Set_Data_Symbol(varargin)
% SET_DATA_SYMBOL MATLAB code for Set_Data_Symbol.fig
%      SET_DATA_SYMBOL, by itself, creates a new SET_DATA_SYMBOL or raises the existing
%      singleton*.
%
%      H = SET_DATA_SYMBOL returns the handle to a new SET_DATA_SYMBOL or the handle to
%      the existing singleton*.
%
%      SET_DATA_SYMBOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SET_DATA_SYMBOL.M with the given input arguments.
%
%      SET_DATA_SYMBOL('Property','Value',...) creates a new SET_DATA_SYMBOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Set_Data_Symbol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Set_Data_Symbol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Set_Data_Symbol

% Last Modified by GUIDE v2.5 11-May-2016 10:22:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Set_Data_Symbol_OpeningFcn, ...
                   'gui_OutputFcn',  @Set_Data_Symbol_OutputFcn, ...
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


% --- Executes just before Set_Data_Symbol is made visible.
function Set_Data_Symbol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Set_Data_Symbol (see VARARGIN)

% Choose default command line output for Set_Data_Symbol
handles.output = hObject;


if nargin < 1
    
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
    
else
%     DataTransfer = varargin{DataTransfer+1};
    handles.MainWindow = varargin{1};
    handles.Defaults = getappdata(varargin{1}, 'Defaults');
end

% DataTransfer = find(strcmp(varargin, 'DataTransfer'));
% if (isempty(DataTransfer)) ...
%         || (length(varargin) <= DataTransfer)% ...
%     
%     disp('------------------------------------------');
%     disp('If you see this, something has gone wrong.')
%     disp('      Please contact Greig Paterson       ')
%     disp('------------------------------------------');
% else
%     DataTransfer = varargin{DataTransfer+1};
%     handles.MainWindow = varargin{3};
%     handles.Defaults = getappdata(varargin{3}, 'Defaults');
%     handles.MainWindow = varargin{4};
% end

% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position');
currentPosition = get(hObject, 'Position');

newX = parentPosition(1) + (parentPosition(3)/1.2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/1.25 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);


Defaults = handles.Defaults;


% Get the data from previous window
% handles.Plot_Symbol = Defaults.Plot_Symbol;
% handles.Symbol_Size = Defaults.Symbol_Size;
% handles.Symbol_Color = Defaults.Symbol_Color;
% handles.Face_Color = Defaults.Face_Color;

handles.All_Symbols = {'^', 'o', 'd', '*', 's', '.', '+'};

% Get the input symbol propoerties to set the deafults
% set the radiobutton
Symb_ind=find(strcmpi(handles.Defaults.DataSymbol, handles.All_Symbols));
Symb_Name = strcat('Sym', sprintf('%d', Symb_ind));
set(handles.(Symb_Name), 'Value', 1);

% Set the filled checkbox
if strcmpi(handles.Defaults.DataFaceColor, 'none')
    set(handles.CB_Filled, 'Value', 0);
else
    set(handles.CB_Filled, 'Value', 1);
end

% Set the symbol size
set(handles.Size_Select, 'Value', handles.Defaults.DataSymbolSize - 2 );

% Update handles structure
guidata(hObject, handles);

% Make the plot
Update_Plot(handles)

uiwait(handles.Set_Data_Symbol_Fig);


% --- Outputs from this function are returned to the command line.
function varargout = Set_Data_Symbol_OutputFcn(hObject, eventdata, handles) 
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

% Return.CancelFlag = 0;
% Return.Plot_Symbol = handles.Plot_Symbol;
% Return.Symbol_Size = handles.Symbol_Size;
% Return.Symbol_Color = handles.Symbol_Color;
% 
% if get(handles.CB_Filled,'Value')
%     Return.Face_Color = handles.Symbol_Color;
% else
%     Return.Face_Color = 'none';
% end
% 
% handles.output = Return;
% guidata(hObject,handles);



% Create a return structure
Return.CancelFlag = 0;
Return.Defaults = handles.Defaults;

handles.output = Return;
guidata(hObject,handles);
uiresume(handles.Set_Data_Symbol_Fig);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Set_Data_Symbol_Fig);


% --- Executes when user attempts to close Set_Data_Symbol_Fig.
function Set_Data_Symbol_Fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Set_Data_Symbol_Fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.Set_Data_Symbol_Fig);

% --- Executes on button press in Set_Color.
function Set_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Defaults.Data_Plot_Color = uisetcolor(handles.Defaults.Data_Plot_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


function Update_Plot(handles)

Defaults = handles.Defaults;

Color = Defaults.Data_Plot_Color;
Size = Defaults.DataSymbolSize;
FaceColor = Defaults.DataFaceColor;

if strcmpi(FaceColor, 'filled')
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
handles.Defaults.DataSymbolSize = str2double(contents{get(hObject,'Value')});

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

if get(hObject,'Value') == 1
    handles.Defaults.DataFaceColor = 'filled';
else
    handles.Defaults.DataFaceColor = 'none';
end

guidata(hObject, handles);

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
        handles.Defaults.DataSymbol = '^';
    case 'Sym2'
        handles.Defaults.DataSymbol = 'o';
    case 'Sym3'
        handles.Defaults.DataSymbol = 'd';
    case 'Sym4'
        handles.Defaults.DataSymbol = '*';
    case 'Sym5'
        handles.Defaults.DataSymbol = 's';
    case 'Sym6'
        handles.Defaults.DataSymbol = '.';
    case 'Sym7'
        handles.Defaults.DataSymbol = '+';
end

guidata(hObject, handles);


% --- Executes on button press in Set_Default.
function Set_Default_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Defaults = handles.Defaults;

% Save them
Save_User_Defaults(Defaults);

% Save them to the main window appdata
setappdata(handles.MainWindow, 'Defaults', Defaults);
