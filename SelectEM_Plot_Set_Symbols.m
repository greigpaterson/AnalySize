function varargout = SelectEM_Plot_Set_Symbols(varargin)
% SELECTEM_PLOT_SET_SYMBOLS MATLAB code for SelectEM_Plot_Set_Symbols.fig
%      SELECTEM_PLOT_SET_SYMBOLS, by itself, creates a new SELECTEM_PLOT_SET_SYMBOLS or raises the existing
%      singleton*.
%
%      H = SELECTEM_PLOT_SET_SYMBOLS returns the handle to a new SELECTEM_PLOT_SET_SYMBOLS or the handle to
%      the existing singleton*.
%
%      SELECTEM_PLOT_SET_SYMBOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTEM_PLOT_SET_SYMBOLS.M with the given input arguments.
%
%      SELECTEM_PLOT_SET_SYMBOLS('Property','Value',...) creates a new SELECTEM_PLOT_SET_SYMBOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectEM_Plot_Set_Symbols_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectEM_Plot_Set_Symbols_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectEM_Plot_Set_Symbols

% Last Modified by GUIDE v2.5 13-Jun-2016 15:28:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectEM_Plot_Set_Symbols_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectEM_Plot_Set_Symbols_OutputFcn, ...
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


% --- Executes just before SelectEM_Plot_Set_Symbols is made visible.
function SelectEM_Plot_Set_Symbols_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectEM_Plot_Set_Symbols (see VARARGIN)

% Choose default command line output for SelectEM_Plot_Set_Symbols
handles.output = hObject;


% DataTransfer = find(strcmp(varargin, 'DataTransfer'));
if nargin < 2
    
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
    
else
%     DataTransfer = varargin{DataTransfer+1};
    handles.MainWindow = varargin{1};
    handles.Defaults = getappdata(varargin{1}, 'Defaults');
    handles.SEMWindow = varargin{2};
end

% keyboard
% Position to be relative to parent:
parentPosition = get(handles.SEMWindow, 'Position');
currentPosition = get(hObject, 'Position');

newX = parentPosition(1) + (parentPosition(3)/1.2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/1.25 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);


% Get the data from previous window
% handles.Plot_Symbol = DataTransfer.Plot_Symbol;
% handles.Symbol_Size = DataTransfer.Symbol_Size;
% handles.Symbol_Color = DataTransfer.Symbol_Color;
% handles.Face_Color = DataTransfer.Face_Color;


Defaults = handles.Defaults;


% Set the symbols and sizes to the pulldown menus
handles.All_Symbols = {'o', 'x', '^', 'd', '*', 's', '.', '+'}';

set(handles.Set_Outlier_Symbol, 'String', handles.All_Symbols, 'Value', find(strcmpi(Defaults.SEM_OLSymbol, handles.All_Symbols)));
set(handles.Set_Outlier_Size, 'Value', Defaults.SEM_OLSymbolSize - 4);

set(handles.Set_EM_Symbol, 'String', handles.All_Symbols, 'Value', find(strcmpi(Defaults.SEM_EMSymbol, handles.All_Symbols)));
set(handles.Set_EM_Size, 'Value', Defaults.SEM_EMSymbolSize - 4);

set(handles.Set_Data_Symbol, 'String', handles.All_Symbols, 'Value', find(strcmpi(Defaults.SEM_DataSymbol, handles.All_Symbols)));
set(handles.Set_Data_Size, 'Value', Defaults.SEM_DataSymbolSize - 4);


% Set the filled checkboxes
if strcmpi(Defaults.SEM_OLFaceColor, 'none')
    set(handles.CB_Outlier_Filled, 'Value', 0);
else
    set(handles.CB_Outlier_Filled, 'Value', 1);
end

if strcmpi(Defaults.SEM_EMFaceColor, 'none')
    set(handles.CB_EM_Filled, 'Value', 0);
else
    set(handles.CB_EM_Filled, 'Value', 1);
end

if strcmpi(Defaults.SEM_DataFaceColor, 'none')
    set(handles.CB_Data_Filled, 'Value', 0);
else
    set(handles.CB_Data_Filled, 'Value', 1);
end


% Update handles structure
guidata(hObject, handles);

% Make the plot
Update_Plot(handles)

% UIWAIT makes SelectEM_Plot_Set_Symbols wait for user response (see UIRESUME)
uiwait(handles.SelectEM_Set_Symbol_Fig);


% --- Outputs from this function are returned to the command line.
function varargout = SelectEM_Plot_Set_Symbols_OutputFcn(hObject, eventdata, handles) 
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

% Create a return structure
Return.CancelFlag = 0;
Return.Defaults = handles.Defaults;

handles.output = Return;
guidata(hObject,handles);

uiresume(handles.SelectEM_Set_Symbol_Fig);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.SelectEM_Set_Symbol_Fig);


% --- Executes when user attempts to close SelectEM_Set_Symbol_Fig.
function SelectEM_Set_Symbol_Fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SelectEM_Set_Symbol_Fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);

Return.CancelFlag = 1;
handles.output = Return;
guidata(hObject,handles);

uiresume(handles.SelectEM_Set_Symbol_Fig);


function Update_Plot(handles)

% PLot params 
width = 0.1;
LineWidth = 1;

Defaults = handles.Defaults;

% Define the box color
Box_Plot_Color = Defaults.SEM_Box_Plot_Color;
Median_Plot_Color = Defaults.SEM_Median_Plot_Color;

% Define the data plot
Data_Plot_Color = Defaults.SEM_Data_Plot_Color;
DataSymbol = Defaults.SEM_DataSymbol;
DataSymbolSize = Defaults.SEM_DataSymbolSize;

if strcmpi(Defaults.SEM_DataFaceColor, 'filled')
    Data_Symbol_Fill = Data_Plot_Color;
else
    Data_Symbol_Fill = 'none';
end

% Define teh End Member plot
EM_Plot_Color = Defaults.SEM_EM_Plot_Color;
EMSymbol = Defaults.SEM_EMSymbol;
EMSymbolSize = Defaults.SEM_EMSymbolSize;

if strcmpi(Defaults.SEM_EMFaceColor, 'filled')
    EM_Symbol_Fill = EM_Plot_Color;
else
    EM_Symbol_Fill = 'none';
end


% Define teh Outlier plot
OL_Plot_Color = Defaults.SEM_Outlier_Plot_Color;
OLSymbol = Defaults.SEM_OLSymbol;
OLSymbolSize = Defaults.SEM_OLSymbolSize;

if strcmpi(Defaults.SEM_OLFaceColor, 'filled')
    OL_Symbol_Fill = OL_Plot_Color;
else
    OL_Symbol_Fill = 'none';
end


cla(handles.Plot_Axes);
set(handles.Plot_Axes, 'Box', 'on');

% set up some "data"
nData = 3;
unit = (1-1/(1+nData))/(1+9/(width+3));

Draw_Data = [linspace(0.7, 0.3, 5)', linspace(0.7, 0.5, 5)', linspace(0.7, 0.6, 5)'];
OL = {[0.8, 0.85, 0.25, 0.28], [0.8, 0.84, 0.4, 0.45], [0.8, 0.82, 0.55, 0.58]};

hold(handles.Plot_Axes, 'on');

for ii = 1:nData
    
    Line = Draw_Data(:,ii);
    
    % Do the whiskers
    
    % Draw the min line
        plot(handles.Plot_Axes, [ii-unit, ii+unit], [Line(5), Line(5)], '-', 'Color', Box_Plot_Color, 'LineWidth', LineWidth);
        % Draw vertical lines
        plot(handles.Plot_Axes, [ii, ii], [Line(4), Line(5)], '-', 'Color', Box_Plot_Color, 'LineWidth', LineWidth);

        % Draw the max line
        plot(handles.Plot_Axes, [ii-unit, ii+unit], [Line(1), Line(1)], '-', 'Color', Box_Plot_Color, 'LineWidth', LineWidth);
        % Draw vertical lines
        plot(handles.Plot_Axes, [ii, ii], [Line(1), Line(2)], '-', 'Color', Box_Plot_Color, 'LineWidth', LineWidth);
    
    
        
            % Draw median line
    plot(handles.Plot_Axes, [ii-unit, ii+unit], [Line(3), Line(3)], '-', 'Color', Median_Plot_Color, 'LineWidth', LineWidth);
    
    % Draw box
    plot(handles.Plot_Axes, [ii-unit, ii+unit, ii+unit, ii-unit, ii-unit], [Line(4), Line(4), Line(2), Line(2), Line(4)], '-', 'Color', Box_Plot_Color, 'LineWidth', LineWidth);
    
    % Draw the outliers
    plot(handles.Plot_Axes, ii, OL{ii}, 'Marker', OLSymbol, 'Color', OL_Plot_Color, 'LineWidth', LineWidth, 'MarkerSize', OLSymbolSize, 'MarkerFaceColor', OL_Symbol_Fill);

        
end

Data_R2 = Draw_Data(3,:) .* [0.8, 0.95, 0.95];
EM_R2 = Draw_Data(5,:) ./ [3, 2, 2]; 



plot(handles.Plot_Axes, 1:nData, Data_R2, '-', 'Marker', DataSymbol, 'Color', Data_Plot_Color, 'LineWidth', LineWidth, 'MarkerSize', DataSymbolSize, 'MarkerFaceColor', Data_Symbol_Fill);

plot(handles.Plot_Axes, 1:nData, EM_R2, '--', 'Marker', EMSymbol, 'Color', EM_Plot_Color, 'LineWidth', LineWidth, 'MarkerSize', EMSymbolSize, 'MarkerFaceColor', EM_Symbol_Fill);

hold(handles.Plot_Axes, 'off')

set(handles.Plot_Axes, 'Xlim', [0.5, nData + 0.5], 'Ylim', [0, 1], 'Box', 'on');
set(handles.Plot_Axes, 'Box', 'on');


% --- Executes on button press in DB_ME.
function DB_ME_Callback(hObject, eventdata, handles)
% hObject    handle to DB_ME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard



% --- Executes on button press in Set_Default.
function Set_Default_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% keyboard;

% Get the defaults, which are already saved in the function calls
Defaults = handles.Defaults;

% Save them
Save_User_Defaults(Defaults);

% Save them to the main window appdata
setappdata(handles.MainWindow, 'Defaults', Defaults);


% --- Executes on button press in Set_Box_Color.
function Set_Box_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Box_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Defaults.SEM_Box_Plot_Color = uisetcolor(handles.Defaults.SEM_Box_Plot_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)

% --- Executes on button press in Set_Median_Color.
function Set_Median_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Median_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Defaults.SEM_Median_Plot_Color = uisetcolor(handles.Defaults.SEM_Median_Plot_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes on button press in Set_Outlier_Color.
function Set_Outlier_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Outlier_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Defaults.SEM_Outlier_Plot_Color = uisetcolor(handles.Defaults.SEM_Outlier_Plot_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes on selection change in Set_Outlier_Size.
function Set_Outlier_Size_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Outlier_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set_Outlier_Size contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set_Outlier_Size

contents = cellstr(get(hObject,'String'));
handles.Defaults.SEM_OLSymbolSize = str2double(contents{get(hObject,'Value')});

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)

% --- Executes during object creation, after setting all properties.
function Set_Outlier_Size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set_Outlier_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Set_Outlier_Symbol.
function Set_Outlier_Symbol_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Outlier_Symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set_Outlier_Symbol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set_Outlier_Symbol

contents = cellstr(get(hObject,'String'));
val = get(handles.Set_Outlier_Symbol, 'Value');
handles.Defaults.SEM_OLSymbol = contents{val};

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes during object creation, after setting all properties.
function Set_Outlier_Symbol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set_Outlier_Symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_Outlier_Filled.
function CB_Outlier_Filled_Callback(hObject, eventdata, handles)
% hObject    handle to CB_Outlier_Filled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_Outlier_Filled

if get(hObject,'Value') == 1
    handles.Defaults.SEM_OLFaceColor = 'filled';
else
    handles.Defaults.SEM_OLFaceColor = 'none';
end

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes on button press in CB_Data_Filled.
function CB_Data_Filled_Callback(hObject, eventdata, handles)
% hObject    handle to CB_Data_Filled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_Data_Filled

if get(hObject,'Value') == 1
    handles.Defaults.SEM_DataFaceColor = 'filled';
else
    handles.Defaults.SEM_DataFaceColor = 'none';
end

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes on button press in Set_Data_Color.
function Set_Data_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Data_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Defaults.SEM_Data_Plot_Color = uisetcolor(handles.Defaults.SEM_Data_Plot_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes on selection change in Set_Data_Size.
function Set_Data_Size_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Data_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set_Data_Size contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set_Data_Size

contents = cellstr(get(hObject,'String'));
handles.Defaults.SEM_DataSymbolSize = str2double(contents{get(hObject,'Value')});

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes during object creation, after setting all properties.
function Set_Data_Size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set_Data_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Set_Data_Symbol.
function Set_Data_Symbol_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Data_Symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set_Data_Symbol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set_Data_Symbol

contents = cellstr(get(hObject,'String'));
val = get(handles.Set_Data_Symbol, 'Value');
handles.Defaults.SEM_DataSymbol = contents{val};

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes during object creation, after setting all properties.
function Set_Data_Symbol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set_Data_Symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_EM_Filled.
function CB_EM_Filled_Callback(hObject, eventdata, handles)
% hObject    handle to CB_EM_Filled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_EM_Filled

if get(hObject,'Value') == 1
    handles.Defaults.SEM_EMFaceColor = 'filled';
else
    handles.Defaults.SEM_EMFaceColor = 'none';
end

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)



% --- Executes on button press in Set_EM_Color.
function Set_EM_Color_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the new color
handles.Defaults.SEM_EM_Plot_Color = uisetcolor(handles.Defaults.SEM_EM_Plot_Color);
guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes on selection change in Set_EM_Size.
function Set_EM_Size_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set_EM_Size contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set_EM_Size

contents = cellstr(get(hObject,'String'));
handles.Defaults.SEM_EMSymbolSize = str2double(contents{get(hObject,'Value')});

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes during object creation, after setting all properties.
function Set_EM_Size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set_EM_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Set_EM_Symbol.
function Set_EM_Symbol_Callback(hObject, eventdata, handles)
% hObject    handle to Set_EM_Symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Set_EM_Symbol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Set_EM_Symbol

contents = cellstr(get(hObject,'String'));
val = get(handles.Set_EM_Symbol, 'Value');
handles.Defaults.SEM_EMSymbol = contents{val};

guidata(hObject, handles);

% Update the plot
Update_Plot(handles)


% --- Executes during object creation, after setting all properties.
function Set_EM_Symbol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Set_EM_Symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
