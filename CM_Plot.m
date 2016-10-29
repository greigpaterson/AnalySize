function varargout = CM_Plot(varargin)
% CM_PLOT MATLAB code for CM_Plot.fig
%      CM_PLOT, by itself, creates a new CM_PLOT or raises the existing
%      singleton*.
%
%      H = CM_PLOT returns the handle to a new CM_PLOT or the handle to
%      the existing singleton*.
%
%      CM_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CM_PLOT.M with the given input arguments.
%
%      CM_PLOT('Property','Value',...) creates a new CM_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CM_Plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CM_Plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CM_Plot

% Last Modified by GUIDE v2.5 08-Jun-2016 15:43:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CM_Plot_OpeningFcn, ...
    'gui_OutputFcn',  @CM_Plot_OutputFcn, ...
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


% --- Executes just before CM_Plot is made visible.
function CM_Plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CM_Plot (see VARARGIN)

% Choose default command line output for CM_Plot
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
end


% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
currentPosition = get(hObject, 'Position');
% Set x and y to be directly in the middle
newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);


% Get the version
Ver = ver('MATLAB');
handles.Version = str2double(Ver.Version);

% Get the data from previous window
handles.Data = DataTransfer.Data;
handles.GS = DataTransfer.GS;
handles.All_Names = DataTransfer.Names;

% Get the C and M values
handles.Cvals = GetPercentile(handles.Data, handles.GS', 99);
handles.Mvals = GetPercentile(handles.Data, handles.GS', 50);

% Get the default plot symbols
handles.Plot_Symbol = handles.Defaults.CMSymbol;
handles.Symbol_Color = handles.Defaults.CM_Plot_Color;
handles.Symbol_Size = handles.Defaults.CMSymbolSize;

if strcmpi(handles.Defaults.CMFaceColor, 'filled')
    handles.Face_Color = handles.Defaults.CM_Plot_Color;
else
    handles.Face_Color = 'none';
end

% Do the plot
Update_Plot(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CM_Plot wait for user response (see UIRESUME)
% uiwait(handles.CM_Plot_Fig);


% --- Outputs from this function are returned to the command line.
function varargout = CM_Plot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in CB_LogX.
function CB_LogX_Callback(hObject, eventdata, handles)
% hObject    handle to CB_LogX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_LogX
Update_Plot(handles)



% --- Executes on button press in CB_LogY.
function CB_LogY_Callback(hObject, eventdata, handles)
% hObject    handle to CB_LogY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_LogY
Update_Plot(handles)


% --- Executes on button press in Set_Symbols.
function Set_Symbols_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Transfer.Plot_Symbol = handles.Plot_Symbol;
Transfer.Symbol_Size = handles.Symbol_Size;
Transfer.Symbol_Color = handles.Symbol_Color;
Transfer.Face_Color = handles.Face_Color;

Return_Data = CM_Plot_Set_Symbols('DataTransfer', Transfer, handles.MainWindow, handles.CM_Plot_Fig);

if Return_Data.CancelFlag == 1
    return;
end

handles.Plot_Symbol = Return_Data.Plot_Symbol;
handles.Symbol_Size = Return_Data.Symbol_Size;
handles.Symbol_Color = Return_Data.Symbol_Color;
handles.Face_Color = Return_Data.Face_Color;

% Save the changes to session defaults
Defaults = handles.Defaults;

Defaults.CMSymbol = handles.Plot_Symbol;
Defaults.CMSymbolSize = handles.Symbol_Size;
Defaults.CM_Plot_Color = handles.Symbol_Color;

if strcmpi(handles.Face_Color, 'none')
    Defaults.CMFaceColor = handles.Face_Color;
else
    Defaults.CMFaceColor = 'filled';
end

handles.Defaults = Defaults;

setappdata(handles.MainWindow, 'Defaults', handles.Defaults);

guidata(hObject, handles);

% Update the plots
Update_Plot(handles)


% --- Executes on button press in Debug.
function Debug_Callback(hObject, eventdata, handles)
% hObject    handle to Debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


function Update_Plot(handles)

FUnits = 'Pixels';
FontSize1 = 12; % 10pt font
FontSize2 = 14; % 14pt font


plot(handles.CM_Axes, handles.Mvals, handles.Cvals, handles.Plot_Symbol,...
    'color', handles.Symbol_Color, 'MarkerSize', handles.Symbol_Size, 'MarkerFaceColor', handles.Face_Color);

% Set the scales
if get(handles.CB_LogX, 'Value') == 1
    set(handles.CM_Axes, 'XScale', 'Log');
end

if get(handles.CB_LogY, 'Value') == 1
    set(handles.CM_Axes, 'YScale', 'Log');
end

set(get(handles.CM_Axes, 'XLabel'), 'String', 'M (\mu{m})', 'FontUnits', FUnits, 'FontSize', FontSize1)
set(get(handles.CM_Axes, 'YLabel'), 'String', 'C (\mu{m})', 'FontUnits', FUnits, 'FontSize', FontSize1);
set(get(handles.CM_Axes, 'Title'), 'String', 'Passega''s CM Plot', 'FontUnits', FUnits, 'FontSize', FontSize2);

% Reset the button down functions
set(handles.CM_Axes, 'ButtonDownFcn', {@CM_Axes_ButtonDownFcn, handles});


% --- Executes on button press in Save_Plot.
function Save_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[file,path] = uiputfile('CM_Plot.eps','Save the CM plot...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

tmpFig=figure('Visible', 'off', 'Units', 'Centimeters');
oldPos=get(tmpFig, 'Position');
set(tmpFig, 'Position', [oldPos(1), oldPos(2), 7.5, 7.5]);

newAxes=copyobj(handles.CM_Axes, tmpFig);
axis square

% Adjust the figure
set(newAxes, 'FontUnits', 'Points', 'FontSize', 9, 'Units', 'Centimeters')
set(get(newAxes, 'XLabel'), 'FontUnits', 'Points', 'FontSize', 10)
set(get(newAxes, 'YLabel'), 'FontUnits', 'Points', 'FontSize', 10);
set(get(newAxes, 'Title'), 'FontUnits', 'Points', 'FontSize', 11);% set(get(newAxes, 'Children'), 'MarkerSize', 6);

% Readjust the x-axis scale and tickmarks
set(newAxes, 'Xlim', get(handles.CM_Axes, 'Xlim'))
set(newAxes, 'XTick', get(handles.CM_Axes, 'XTick'))
set(newAxes, 'XTickLabel', get(handles.CM_Axes, 'XTickLabel'))

% Adjust size
NewPos = [1.5, 1.5, 4.5, 4.5];
set(newAxes, 'Position', NewPos, 'XColor', [1,1,1], 'YColor', [1,1,1], 'Box', 'off', 'TickDir', 'Out');


% Place a new set of axes on top to create the box
if handles.Version <= 8.3 % 2014a and before
    h0 = axes('Units', 'Centimeters', 'Position', NewPos);
    set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');
else% 2014b and later
    h0=copyobj(newAxes, tmpFig);
    cla(h0);
    set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');
    set(h0, 'Title', [], 'XLabel', [], 'YLabel', []);
end

% keyboard

print(tmpFig, '-depsc', strcat(path, file));
close(tmpFig);



% --- Executes on button press in Export_Data.
function Export_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[file, path] = uiputfile('CM_Data.dat', 'Save CM plot data...');


if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

LineEnd = getappdata(handles.MainWindow, 'LineEnd');


Header = [{'Specimen'}, {'M (microns)'}, {'C (microns)'}];
Data = [handles.All_Names, num2cell([handles.Mvals, handles.Cvals])]';

% File formats
fmt1 = strcat('%s\t%s\t%s', LineEnd);
fmt2 = strcat('%s\t%f\t%f', LineEnd);


fout = fopen(strcat(path, file), 'wt');
fprintf(fout, fmt1, Header{:});

fprintf(fout, fmt2, Data{:});

fclose(fout);


% --- Executes on mouse press over axes background.
function CM_Axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to CM_Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PopOutFigure(handles.CM_Axes, 'CM Plot Figure')
